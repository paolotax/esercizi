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

    // Inizializza drop zone - usa event capturing per catturare eventi sulla griglia interna
    this.dropZoneTarget.addEventListener('dragover', this.handleDragOver.bind(this), true)
    this.dropZoneTarget.addEventListener('drop', this.handleDrop.bind(this), true)
    this.dropZoneTarget.addEventListener('dragleave', this.handleDragLeave.bind(this))

    // Inizializza drag per operazioni esistenti
    this.initializeExistingOperations()
  }

  initializeExistingOperations() {
    const operations = this.dropZoneTarget.querySelectorAll('.operation-item')
    operations.forEach(op => {
      op.addEventListener('dragstart', this.handleOperationDragStart.bind(this))
      op.addEventListener('dragend', this.handleOperationDragEnd.bind(this))
      op.addEventListener('dragover', this.handleOperationDragOver.bind(this))
      op.addEventListener('drop', this.handleOperationDrop.bind(this))
      // Aggiungi click per aprire le proprietà
      op.addEventListener('click', this.handleOperationClick.bind(this))
      // Aggiungi classe per indicare che è cliccabile
      op.classList.add('cursor-pointer', 'hover:shadow-lg', 'transition-shadow')
    })
  }

  handleOperationClick(e) {
    // Previeni click sui pulsanti interni
    if (e.target.closest('button')) {
      return
    }

    const operationElement = e.currentTarget
    const operationId = operationElement.dataset.operationId
    const operationType = operationElement.dataset.operationType

    // Rimuovi selezione precedente
    this.dropZoneTarget.querySelectorAll('.operation-item').forEach(op => {
      op.classList.remove('ring-2', 'ring-blue-500')
    })

    // Evidenzia l'operazione selezionata
    operationElement.classList.add('ring-2', 'ring-blue-500')

    // Dispatch evento per aprire il pannello proprietà
    document.dispatchEvent(new CustomEvent('open-properties', {
      detail: { operationId, operationType }
    }))
  }

  handleDragStart(e) {
    const generator = e.target.closest('.operation-generator')
    const operationType = generator ? generator.dataset.operationType : e.target.dataset.operationType
    console.log("handleDragStart - operationType:", operationType)
    e.dataTransfer.effectAllowed = 'copy'
    e.dataTransfer.setData('operationType', operationType)
    e.dataTransfer.setData('isNew', 'true')
    e.target.classList.add('dragging')
  }

  handleOperationDragStart(e) {
    const operationItem = e.target.closest('.operation-item')
    if (!operationItem) return

    const operationId = operationItem.dataset.operationId
    console.log("handleOperationDragStart - operationId:", operationId)

    e.dataTransfer.effectAllowed = 'move'
    e.dataTransfer.setData('operationId', operationId)
    e.dataTransfer.setData('isNew', 'false')
    operationItem.classList.add('dragging')
    this.draggedElement = operationItem
  }

  handleDragEnd(e) {
    e.target.classList.remove('dragging')
  }

  handleOperationDragEnd(e) {
    const operationItem = e.target.closest('.operation-item')
    if (operationItem) {
      operationItem.classList.remove('dragging')
    }
    // Rimuovi tutti gli indicatori di inserimento
    this.dropZoneTarget.querySelectorAll('.operation-item').forEach(op => {
      op.classList.remove('drag-over-top', 'drag-over-bottom')
    })
    this.draggedElement = null
  }

  handleOperationDragOver(e) {
    e.preventDefault()
    e.stopPropagation()

    const targetOperation = e.target.closest('.operation-item')
    if (!targetOperation) return
    if (!this.draggedElement || this.draggedElement === targetOperation) return

    const afterElement = this.getDragAfterElement(targetOperation, e.clientY)

    // Rimuovi classi da tutti gli elementi
    this.dropZoneTarget.querySelectorAll('.operation-item').forEach(op => {
      op.classList.remove('drag-over-top', 'drag-over-bottom')
    })

    // Aggiungi indicatore visuale
    if (afterElement) {
      targetOperation.classList.add('drag-over-bottom')
    } else {
      targetOperation.classList.add('drag-over-top')
    }
  }

  handleOperationDrop(e) {
    e.preventDefault()
    e.stopPropagation()

    const targetOperation = e.target.closest('.operation-item')
    if (!targetOperation) return
    if (!this.draggedElement || this.draggedElement === targetOperation) return

    console.log("handleOperationDrop - moving operation")

    const afterElement = this.getDragAfterElement(targetOperation, e.clientY)

    if (afterElement) {
      // Inserisci dopo l'elemento target
      targetOperation.parentNode.insertBefore(this.draggedElement, targetOperation.nextSibling)
    } else {
      // Inserisci prima dell'elemento target
      targetOperation.parentNode.insertBefore(this.draggedElement, targetOperation)
    }

    // Rimuovi indicatori visuali
    this.dropZoneTarget.querySelectorAll('.operation-item').forEach(op => {
      op.classList.remove('drag-over-top', 'drag-over-bottom')
    })

    // Salva il nuovo ordine
    this.saveOperationsOrder()
  }

  getDragAfterElement(container, y) {
    const box = container.getBoundingClientRect()
    const offset = y - box.top - box.height / 2
    return offset > 0
  }

  handleDragOver(e) {
    e.preventDefault()
    e.stopPropagation()

    // Determina se stiamo trascinando una nuova operazione o riordinando
    const isNew = this.draggedElement === null
    e.dataTransfer.dropEffect = isNew ? 'copy' : 'move'

    this.dropZoneTarget.classList.add('drag-over')

    // Mostra indicatore di posizionamento
    this.showDropIndicator(e)
  }

  showDropIndicator(e) {
    const existingOperations = this.dropZoneTarget.querySelectorAll('.operation-item')

    // Rimuovi tutti gli indicatori precedenti
    existingOperations.forEach(op => {
      op.classList.remove('drag-over-top', 'drag-over-bottom', 'drag-over-left', 'drag-over-right')
    })

    // Se non ci sono operazioni, non serve indicatore
    if (existingOperations.length === 0) return

    const mouseX = e.clientX
    const mouseY = e.clientY

    let closestElement = null
    let closestDistance = Infinity
    let position = 'before'

    // Trova l'elemento più vicino al cursore
    existingOperations.forEach((op) => {
      const rect = op.getBoundingClientRect()
      const centerX = rect.left + rect.width / 2
      const centerY = rect.top + rect.height / 2

      // Calcola la distanza dal centro dell'elemento
      const distance = Math.sqrt(
        Math.pow(mouseX - centerX, 2) + Math.pow(mouseY - centerY, 2)
      )

      if (distance < closestDistance) {
        closestDistance = distance
        closestElement = op

        // Determina se inserire prima o dopo basandosi sulla posizione relativa
        const deltaX = mouseX - centerX
        const deltaY = mouseY - centerY

        // Se siamo principalmente sopra/sotto
        if (Math.abs(deltaY) > Math.abs(deltaX)) {
          position = deltaY < 0 ? 'top' : 'bottom'
        } else {
          // Se siamo principalmente a sinistra/destra
          position = deltaX < 0 ? 'left' : 'right'
        }
      }
    })

    // Applica la classe appropriata
    if (closestElement) {
      if (position === 'top' || position === 'left') {
        closestElement.classList.add('drag-over-top')
      } else {
        closestElement.classList.add('drag-over-bottom')
      }
    }
  }

  handleDragLeave(e) {
    if (e.target === this.dropZoneTarget) {
      this.dropZoneTarget.classList.remove('drag-over')
      // Rimuovi indicatori di posizionamento
      const existingOperations = this.dropZoneTarget.querySelectorAll('.operation-item')
      existingOperations.forEach(op => {
        op.classList.remove('drag-over-top', 'drag-over-bottom')
      })
    }
  }

  async handleDrop(e) {
    console.log("handleDrop called")
    e.preventDefault()
    e.stopPropagation()
    this.dropZoneTarget.classList.remove('drag-over')

    // Rimuovi tutti gli indicatori di posizionamento
    const existingOperations = this.dropZoneTarget.querySelectorAll('.operation-item')
    existingOperations.forEach(op => {
      op.classList.remove('drag-over-top', 'drag-over-bottom')
    })

    const isNew = e.dataTransfer.getData('isNew') === 'true'
    console.log("Drop event - isNew:", isNew)

    if (isNew) {
      const operationType = e.dataTransfer.getData('operationType')
      console.log("Adding new operation:", operationType)

      // Determina la posizione dove inserire l'operazione
      const position = this.getDropPosition(e)
      console.log("Position calculated:", position)

      if (operationType) {
        await this.addNewOperation(operationType, position)
      } else {
        console.error("No operation type found in dataTransfer!")
      }
    } else {
      // Riordinamento operazione esistente
      const operationId = e.dataTransfer.getData('operationId')
      console.log('Riordinamento operazione:', operationId)

      if (this.draggedElement) {
        const targetOperation = e.target.closest('.operation-item')

        if (targetOperation && targetOperation !== this.draggedElement) {
          // Determina se inserire prima o dopo
          const afterElement = this.getDragAfterElement(targetOperation, e.clientY)

          if (afterElement) {
            targetOperation.parentNode.insertBefore(this.draggedElement, targetOperation.nextSibling)
          } else {
            targetOperation.parentNode.insertBefore(this.draggedElement, targetOperation)
          }

          console.log("Operation moved, saving order...")
          await this.saveOperationsOrder()
        } else if (!targetOperation) {
          // Drop su area vuota - sposta alla fine
          const operationsGrid = this.dropZoneTarget.querySelector('#operations-grid')
          if (operationsGrid) {
            operationsGrid.appendChild(this.draggedElement)
            console.log("Operation moved to end, saving order...")
            await this.saveOperationsOrder()
          }
        }
      }
    }
  }

  getDropPosition(e) {
    const existingOperations = this.dropZoneTarget.querySelectorAll('.operation-item')
    if (existingOperations.length === 0) return 0

    const mouseX = e.clientX
    const mouseY = e.clientY

    // Trova l'operazione più vicina al cursore
    let closestOperation = null
    let closestDistance = Infinity
    let insertBefore = false

    Array.from(existingOperations).forEach((op, index) => {
      const rect = op.getBoundingClientRect()
      const centerX = rect.left + rect.width / 2
      const centerY = rect.top + rect.height / 2

      // Calcola la distanza dal centro dell'elemento
      const distance = Math.sqrt(Math.pow(mouseX - centerX, 2) + Math.pow(mouseY - centerY, 2))

      if (distance < closestDistance) {
        closestDistance = distance
        closestOperation = { element: op, index: index, rect: rect }

        // Determina se inserire prima o dopo basandosi sulla posizione del mouse
        if (mouseY < centerY) {
          // Mouse sopra il centro - inserisci prima
          insertBefore = true
        } else if (mouseY > centerY) {
          // Mouse sotto il centro - inserisci dopo
          insertBefore = false
        } else {
          // Stessa altezza, usa X
          insertBefore = mouseX < centerX
        }
      }
    })

    if (!closestOperation) {
      return existingOperations.length // Aggiungi alla fine
    }

    // Ritorna la posizione corretta per l'inserimento
    return insertBefore ? closestOperation.index : closestOperation.index + 1
  }

  async addNewOperation(type, position = null) {
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
          config: config,
          position: position
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
        const icon = this.getOperationIcon(operation.type)
        html += `
          <div class="operation-item ${bgColor} p-4 rounded-lg border-2 border-dashed border-gray-300 cursor-pointer hover:shadow-lg transition-shadow"
               data-operation-id="${operation.id}"
               data-operation-type="${operation.type}"
               draggable="true">
            <div class="flex justify-between items-start mb-3">
              <div class="flex items-center gap-2">
                ${icon}
                <span class="font-semibold text-gray-700">${operation.type.charAt(0).toUpperCase() + operation.type.slice(1)}</span>
              </div>
              <button class="text-red-500 hover:text-red-700 transition"
                      data-action="click->esercizio-builder#removeOperation"
                      data-operation-id="${operation.id}">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                </svg>
              </button>
            </div>
            ${this.renderOperationPreview(operation)}
            <div class="text-xs text-gray-400 text-center mt-3 pt-2 border-t border-gray-200">
              Clicca per modificare • Trascina per riordinare
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

  getOperationIcon(type) {
    const icons = {
      'addizione': '<svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path></svg>',
      'sottrazione': '<svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 12H4"></path></svg>',
      'moltiplicazione': '<svg class="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>',
      'abaco': '<svg class="w-5 h-5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path></svg>'
    }
    return icons[type] || ''
  }

  renderOperationPreview(operation) {
    const config = operation.config || {}
    let html = '<div class="space-y-2">'

    // Titolo se presente
    if (config.title) {
      html += `<div class="text-sm font-medium text-gray-800">📝 ${config.title}</div>`
    }

    // Operazione
    if (config.operation_text) {
      html += `<div class="font-mono text-lg text-gray-700 bg-white px-3 py-2 rounded border border-gray-200">${config.operation_text}</div>`
    } else if (config.values && config.values.length > 0) {
      html += '<div class="font-mono text-lg text-gray-700">'
      switch(operation.type) {
        case 'addizione':
          html += config.values.join(' + ')
          break
        case 'sottrazione':
          html += config.values.join(' - ')
          break
        case 'moltiplicazione':
          html += config.multiplicand && config.multiplier ? `${config.multiplicand} × ${config.multiplier}` : ''
          break
        case 'abaco':
          html += config.value || config.values?.[0] || ''
          break
      }
      html += '</div>'
    } else {
      html += '<div class="text-sm text-gray-500 italic">Operazione vuota - clicca per configurare</div>'
    }

    // Opzioni attive
    html += '<div class="flex flex-wrap gap-1 mt-2">'
    if (config.show_toolbar === true) {
      html += '<span class="inline-flex items-center px-2 py-1 text-xs bg-gray-200 text-gray-600 rounded">🛠️ Toolbar</span>'
    }
    if (config.show_solution === true) {
      html += '<span class="inline-flex items-center px-2 py-1 text-xs bg-green-200 text-green-700 rounded">✓ Risultato</span>'
    }
    if (config.show_carry === true || config.show_borrow === true) {
      html += '<span class="inline-flex items-center px-2 py-1 text-xs bg-blue-200 text-blue-700 rounded">↗️ Riporti</span>'
    }
    if (config.show_addends === true) {
      html += '<span class="inline-flex items-center px-2 py-1 text-xs bg-yellow-200 text-yellow-700 rounded">📊 Valori</span>'
    }
    if (config.show_partial_products === true) {
      html += '<span class="inline-flex items-center px-2 py-1 text-xs bg-purple-200 text-purple-700 rounded">📋 Parziali</span>'
    }
    html += '</div>'

    html += '</div>'
    return html
  }

  getDefaultConfig(type) {
    switch(type) {
      case 'addizione':
        return {
          operation_text: '',  // Vuoto per inserimento manuale
          show_carry: true,
          show_toolbar: false,
          show_solution: false
        }
      case 'sottrazione':
        return {
          operation_text: '',  // Vuoto per inserimento manuale
          show_borrow: true,
          show_toolbar: false,
          show_solution: false
        }
      case 'moltiplicazione':
        return {
          operation_text: '',  // Vuoto per inserimento manuale
          show_partial_products: false,
          show_toolbar: false
        }
      case 'abaco':
        return {
          operation_text: '',  // Vuoto per inserimento manuale
          show_value: false,
          editable: true,
          max_per_column: 9
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

  async saveOperationsOrder() {
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
        this.showNotification('Ordine aggiornato', 'success')
      } else {
        this.showNotification('Errore nel salvataggio dell\'ordine', 'error')
      }
    } catch (error) {
      console.error('Errore:', error)
      this.showNotification('Errore di connessione', 'error')
    }
  }

  async saveLayout() {
    // Alias per compatibilità
    await this.saveOperationsOrder()
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