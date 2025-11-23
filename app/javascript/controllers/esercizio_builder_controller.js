import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropZone", "propertiesForm"]

  connect() {
    console.log("✅ Esercizio Builder Controller connected!")
    this.initializeDragAndDrop()
    this.esercizioId = this.dropZoneTarget.dataset.esercizioId
    console.log("Esercizio ID:", this.esercizioId)
  }

  initializeDragAndDrop() {
    // Inizializza drag per i generatori
    const generators = document.querySelectorAll('.operation-generator')
    console.log(`Found ${generators.length} generators`)

    generators.forEach(generator => {
      generator.addEventListener('dragstart', this.handleDragStart.bind(this))
      generator.addEventListener('dragend', this.handleDragEnd.bind(this))
    })

    // Inizializza drop zone
    this.dropZoneTarget.addEventListener('dragover', this.handleDragOver.bind(this))
    this.dropZoneTarget.addEventListener('drop', this.handleDrop.bind(this))
    this.dropZoneTarget.addEventListener('dragleave', this.handleDragLeave.bind(this))

    // Inizializza drag per operazioni esistenti
    this.initializeExistingOperations()
  }

  initializeExistingOperations() {
    const operations = this.dropZoneTarget.querySelectorAll('.operation-item')
    operations.forEach(op => {
      op.addEventListener('dragstart', this.handleOperationDragStart.bind(this))
      op.addEventListener('dragend', this.handleOperationDragEnd.bind(this))
    })
  }

  handleDragStart(e) {
    e.dataTransfer.effectAllowed = 'copy'
    e.dataTransfer.setData('operationType', e.target.dataset.operationType)
    e.dataTransfer.setData('isNew', 'true')
    e.target.classList.add('dragging')
  }

  handleOperationDragStart(e) {
    e.dataTransfer.effectAllowed = 'move'
    e.dataTransfer.setData('operationId', e.target.dataset.operationId)
    e.dataTransfer.setData('isNew', 'false')
    e.target.classList.add('dragging')
    this.draggedElement = e.target
  }

  handleDragEnd(e) {
    e.target.classList.remove('dragging')
  }

  handleOperationDragEnd(e) {
    e.target.classList.remove('dragging')
    this.draggedElement = null
  }

  handleDragOver(e) {
    e.preventDefault()
    e.dataTransfer.dropEffect = 'copy'
    this.dropZoneTarget.classList.add('drag-over')
  }

  handleDragLeave(e) {
    if (e.target === this.dropZoneTarget) {
      this.dropZoneTarget.classList.remove('drag-over')
    }
  }

  async handleDrop(e) {
    e.preventDefault()
    e.stopPropagation()
    this.dropZoneTarget.classList.remove('drag-over')

    const isNew = e.dataTransfer.getData('isNew') === 'true'
    console.log("Drop event - isNew:", isNew)

    if (isNew) {
      const operationType = e.dataTransfer.getData('operationType')
      console.log("Adding new operation:", operationType)
      if (operationType) {
        await this.addNewOperation(operationType)
      }
    } else {
      const operationId = e.dataTransfer.getData('operationId')
      // Qui potresti implementare il riordinamento
      console.log('Riordinamento operazione:', operationId)
    }
  }

  async addNewOperation(type) {
    const config = this.getDefaultConfig(type)

    try {
      const response = await fetch(`/dashboard/esercizi/${this.esercizioId}/add_operation`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          operation_type: type,
          config: config
        })
      })

      if (response.ok) {
        const data = await response.json()
        // Usa l'HTML renderizzato dal server invece di ricreare il DOM
        if (data.html) {
          this.dropZoneTarget.innerHTML = data.html
          this.initializeExistingOperations() // Re-inizializza drag & drop
        } else {
          this.renderOperations(data.operations)
        }
        this.showNotification('Operazione aggiunta con successo', 'success')
      } else {
        this.showNotification('Errore nell\'aggiunta dell\'operazione', 'error')
      }
    } catch (error) {
      console.error('Errore:', error)
      this.showNotification('Errore di connessione', 'error')
    }
  }

  async removeOperation(e) {
    const operationId = e.currentTarget.dataset.operationId

    if (!confirm('Sei sicuro di voler rimuovere questa operazione?')) {
      return
    }

    try {
      const response = await fetch(`/dashboard/esercizi/${this.esercizioId}/remove_operation`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          operation_id: operationId
        })
      })

      if (response.ok) {
        const data = await response.json()
        this.renderOperations(data.operations)
        this.showNotification('Operazione rimossa', 'success')
      } else {
        this.showNotification('Errore nella rimozione', 'error')
      }
    } catch (error) {
      console.error('Errore:', error)
      this.showNotification('Errore di connessione', 'error')
    }
  }

  renderOperations(operations) {
    if (operations.length === 0) {
      // Mostra empty state
      this.dropZoneTarget.innerHTML = `
        <div class="flex flex-col items-center justify-center h-[400px] text-gray-400">
          <svg class="w-16 h-16 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"></path>
          </svg>
          <p class="text-lg font-medium mb-2">Trascina qui le operazioni</p>
          <p class="text-sm">Seleziona un generatore dalla barra laterale e trascinalo in quest'area</p>
        </div>
      `
    } else {
      // Renderizza griglia operazioni
      let html = '<div class="grid grid-cols-1 md:grid-cols-2 gap-4" id="operations-grid">'

      operations.forEach(operation => {
        const bgColor = this.getOperationColor(operation.type)
        html += `
          <div class="operation-item ${bgColor} p-4 rounded-lg border-2 border-dashed border-gray-300"
               data-operation-id="${operation.id}"
               data-operation-type="${operation.type}"
               draggable="true">
            <div class="flex justify-between items-start mb-2">
              <span class="font-medium">${operation.type.charAt(0).toUpperCase() + operation.type.slice(1)}</span>
              <button class="text-red-500 hover:text-red-700"
                      data-action="click->esercizio-builder#removeOperation"
                      data-operation-id="${operation.id}">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                </svg>
              </button>
            </div>
            <div class="text-sm text-gray-600">
              ${this.renderOperationPreview(operation)}
            </div>
          </div>
        `
      })

      html += '</div>'
      this.dropZoneTarget.innerHTML = html

      // Re-inizializza eventi per nuove operazioni
      this.initializeExistingOperations()
    }
  }

  getOperationColor(type) {
    const colors = {
      'addizione': 'bg-blue-50',
      'sottrazione': 'bg-red-50',
      'moltiplicazione': 'bg-green-50',
      'abaco': 'bg-purple-50'
    }
    return colors[type] || 'bg-gray-50'
  }

  renderOperationPreview(operation) {
    const config = operation.config || {}

    switch(operation.type) {
      case 'addizione':
        return `Addizione: ${config.max_value || 100} (max)`
      case 'sottrazione':
        return `Sottrazione: ${config.max_value || 100} (max)`
      case 'moltiplicazione':
        return `Moltiplicazione: ${config.max_table || 10} × ${config.max_table || 10}`
      case 'abaco':
        return `Abaco: ${config.max_value || 999} (max)`
      default:
        return 'Configurazione personalizzata'
    }
  }

  getDefaultConfig(type) {
    switch(type) {
      case 'addizione':
        return {
          min_value: 1,
          max_value: 20,
          allow_carry: false
        }
      case 'sottrazione':
        return {
          min_value: 1,
          max_value: 20,
          allow_borrow: false
        }
      case 'moltiplicazione':
        return {
          min_table: 1,
          max_table: 10
        }
      case 'abaco':
        return {
          min_value: 1,
          max_value: 100,
          show_hundreds: false
        }
      default:
        return {}
    }
  }

  clearAll() {
    if (!confirm('Sei sicuro di voler rimuovere tutte le operazioni?')) {
      return
    }

    // Implementa la logica per svuotare tutto
    this.renderOperations([])
  }

  async saveLayout() {
    // Raccogli l'ordine corrente delle operazioni
    const operations = this.dropZoneTarget.querySelectorAll('.operation-item')
    const operationIds = Array.from(operations).map(op => op.dataset.operationId)

    try {
      const response = await fetch(`/dashboard/esercizi/${this.esercizioId}/reorder_operations`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          operation_ids: operationIds
        })
      })

      if (response.ok) {
        this.showNotification('Layout salvato con successo', 'success')
      } else {
        this.showNotification('Errore nel salvataggio', 'error')
      }
    } catch (error) {
      console.error('Errore:', error)
      this.showNotification('Errore di connessione', 'error')
    }
  }

  showNotification(message, type) {
    // Crea notifica temporanea
    const notification = document.createElement('div')
    notification.className = `fixed top-4 right-4 px-6 py-3 rounded-lg shadow-lg z-50 ${
      type === 'success' ? 'bg-green-500 text-white' : 'bg-red-500 text-white'
    }`
    notification.textContent = message

    document.body.appendChild(notification)

    setTimeout(() => {
      notification.remove()
    }, 3000)
  }
}