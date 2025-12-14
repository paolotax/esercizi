import { Controller } from "@hotwired/stimulus"

/**
 * Controller per la sidebar overlay delle operazioni in quaderno
 * Permette di aprire una sidebar laterale con l'operazione in formato quaderno
 * e salvare il risultato nell'input principale
 */
export default class extends Controller {
  static targets = ["sidebar", "backdrop", "title", "content"]

  connect() {
    // Chiudi con Escape
    this.boundHandleEscape = this.handleEscape.bind(this)
    document.addEventListener('keydown', this.boundHandleEscape)
  }

  disconnect() {
    document.removeEventListener('keydown', this.boundHandleEscape)
  }

  handleEscape(event) {
    if (event.key === 'Escape' && !this.sidebarTarget.classList.contains('translate-x-full')) {
      this.close()
    }
  }

  async open(event) {
    event.preventDefault()
    const button = event.currentTarget

    // Memorizza i dati per il salvataggio
    this.targetInputId = button.dataset.targetInput
    this.operation = button.dataset.operation
    this.operationType = button.dataset.type || 'addizione'
    this.isGroup = false

    // Aggiorna il titolo
    const titles = {
      'addizione': 'Addizione in colonna',
      'sottrazione': 'Sottrazione in colonna',
      'moltiplicazione': 'Moltiplicazione in colonna',
      'divisione': 'Divisione in colonna'
    }
    if (this.hasTitleTarget) {
      this.titleTarget.textContent = titles[this.operationType] || 'Operazione in colonna'
    }

    // Mostra loading
    this.contentTarget.innerHTML = '<div class="text-center py-8 text-gray-500">Caricamento...</div>'

    // Mostra sidebar con animazione
    this.backdropTarget.classList.remove('hidden')
    // Piccolo delay per permettere la transizione
    requestAnimationFrame(() => {
      this.sidebarTarget.classList.remove('translate-x-full')
    })

    // Fetch del partial quaderno
    try {
      const url = `/exercises/quaderno_grid?operation=${encodeURIComponent(this.operation)}&type=${this.operationType}`
      const response = await fetch(url)

      if (!response.ok) {
        throw new Error('Errore nel caricamento')
      }

      this.contentTarget.innerHTML = await response.text()

      // Focus sul primo input dopo un breve delay
      setTimeout(() => {
        const firstInput = this.contentTarget.querySelector('input:not([readonly]):not([disabled])')
        if (firstInput) {
          firstInput.focus()
          firstInput.select()
        }
      }, 150)

    } catch (error) {
      console.error('Errore nel caricamento del quaderno:', error)
      this.contentTarget.innerHTML = '<div class="text-center py-8 text-red-500">Errore nel caricamento</div>'
    }
  }

  async openGroup(event) {
    event.preventDefault()
    const button = event.currentTarget

    // Memorizza i dati per il salvataggio multiplo
    this.operationsData = JSON.parse(button.dataset.operations || '[]')
    this.operationType = button.dataset.type || 'moltiplicazione'
    this.isGroup = true
    this.groupLetter = button.dataset.group || ''

    // Aggiorna il titolo
    const titles = {
      'addizione': 'Addizioni in colonna',
      'sottrazione': 'Sottrazioni in colonna',
      'moltiplicazione': 'Moltiplicazioni in colonna',
      'divisione': 'Divisioni in colonna'
    }
    if (this.hasTitleTarget) {
      this.titleTarget.textContent = `${titles[this.operationType] || 'Operazioni in colonna'} - Gruppo ${this.groupLetter}`
    }

    // Mostra loading
    this.contentTarget.innerHTML = '<div class="text-center py-8 text-gray-500">Caricamento...</div>'

    // Mostra sidebar con animazione
    this.backdropTarget.classList.remove('hidden')
    requestAnimationFrame(() => {
      this.sidebarTarget.classList.remove('translate-x-full')
    })

    // Fetch di tutti i partial quaderno
    try {
      const htmlParts = []
      for (const op of this.operationsData) {
        let url = `/exercises/quaderno_grid?operation=${encodeURIComponent(op.operation)}&type=${this.operationType}`
        // Aggiungi show_partial_carries se specificato nell'operazione
        if (op.showPartialCarries) {
          url += '&show_partial_carries=true'
        }
        const response = await fetch(url)
        if (!response.ok) {
          throw new Error('Errore nel caricamento')
        }
        const html = await response.text()
        // Wrap each quaderno with operation id for saving
        htmlParts.push(`<div class="quaderno-group-item mb-4" data-target-input="${op.targetId}">${html}</div>`)
      }

      // Contenitore verticale per i quaderni
      this.contentTarget.innerHTML = `<div class="flex flex-col items-center gap-2">${htmlParts.join('')}</div>`

      // Focus sul primo input dopo un breve delay
      setTimeout(() => {
        const firstInput = this.contentTarget.querySelector('input:not([readonly]):not([disabled])')
        if (firstInput) {
          firstInput.focus()
          firstInput.select()
        }
      }, 150)

    } catch (error) {
      console.error('Errore nel caricamento del quaderno:', error)
      this.contentTarget.innerHTML = '<div class="text-center py-8 text-red-500">Errore nel caricamento</div>'
    }
  }

  close() {
    // Nascondi sidebar con animazione
    this.sidebarTarget.classList.add('translate-x-full')

    // Nascondi backdrop dopo la transizione
    setTimeout(() => {
      this.backdropTarget.classList.add('hidden')
      // Pulisci il contenuto
      this.contentTarget.innerHTML = ''
    }, 300) // Stesso tempo della transizione CSS
  }

  save() {
    if (this.isGroup) {
      this.saveGroup()
    } else {
      this.saveSingle()
    }
    this.close()
  }

  saveSingle() {
    // Estrae il risultato dal quaderno in base al tipo
    let resultInputs
    let commaSelector = null

    switch (this.operationType) {
      case 'addizione':
        resultInputs = this.contentTarget.querySelectorAll('input[data-quaderno-addition-target="result"]')
        break
      case 'sottrazione':
        resultInputs = this.contentTarget.querySelectorAll('input[data-quaderno-subtraction-target="result"]')
        break
      case 'moltiplicazione':
        resultInputs = this.contentTarget.querySelectorAll('input[data-quaderno-multiplication-target="result"]')
        commaSelector = '[data-quaderno-multiplication-target="commaSpot"].active'
        break
      case 'divisione':
        resultInputs = this.contentTarget.querySelectorAll('input[data-quaderno-division-target="quotient"]')
        commaSelector = '[data-quaderno-division-target="commaSpot"].active'
        break
      default:
        resultInputs = []
    }

    // Concatena i valori degli input del risultato
    let result = ''
    resultInputs.forEach(input => {
      result += input.value || ''
    })

    // Trova la posizione della virgola (se presente)
    if (commaSelector) {
      const activeComma = this.contentTarget.querySelector(commaSelector)
      if (activeComma) {
        const decimalPlaces = parseInt(activeComma.dataset.position) || 0
        if (decimalPlaces > 0 && result.length > decimalPlaces) {
          // Inserisci la virgola nella posizione corretta
          const integerPart = result.slice(0, result.length - decimalPlaces)
          const decimalPart = result.slice(result.length - decimalPlaces)
          result = integerPart + ',' + decimalPart
        }
      }
    }

    // Rimuovi spazi e zeri iniziali (celle vuote a sinistra)
    result = result.replace(/^\s+/, '').replace(/^0+(?=\d)/, '')

    // Inserisce nell'input target
    if (this.targetInputId && result) {
      this.updateTargetInput(this.targetInputId, result)
    }
  }

  saveGroup() {
    // Per ogni quaderno nel gruppo, estrai il risultato e salvalo
    const groupItems = this.contentTarget.querySelectorAll('.quaderno-group-item')

    groupItems.forEach(item => {
      const targetInputId = item.dataset.targetInput
      let resultInputs
      let commaSelector = null

      switch (this.operationType) {
        case 'addizione':
          resultInputs = item.querySelectorAll('input[data-quaderno-addition-target="result"]')
          break
        case 'sottrazione':
          resultInputs = item.querySelectorAll('input[data-quaderno-subtraction-target="result"]')
          break
        case 'moltiplicazione':
          resultInputs = item.querySelectorAll('input[data-quaderno-multiplication-target="result"]')
          commaSelector = '[data-quaderno-multiplication-target="commaSpot"].active'
          break
        case 'divisione':
          resultInputs = item.querySelectorAll('input[data-quaderno-division-target="quotient"]')
          commaSelector = '[data-quaderno-division-target="commaSpot"].active'
          break
        default:
          resultInputs = []
      }

      // Concatena i valori degli input del risultato
      let result = ''
      resultInputs.forEach(input => {
        result += input.value || ''
      })

      // Trova la posizione della virgola (se presente)
      if (commaSelector) {
        const activeComma = item.querySelector(commaSelector)
        if (activeComma) {
          const decimalPlaces = parseInt(activeComma.dataset.position) || 0
          if (decimalPlaces > 0 && result.length > decimalPlaces) {
            const integerPart = result.slice(0, result.length - decimalPlaces)
            const decimalPart = result.slice(result.length - decimalPlaces)
            result = integerPart + ',' + decimalPart
          }
        }
      }

      // Rimuovi spazi e zeri iniziali
      result = result.replace(/^\s+/, '').replace(/^0+(?=\d)/, '')

      // Inserisce nell'input target
      if (targetInputId && result) {
        this.updateTargetInput(targetInputId, result)
      }
    })
  }

  updateTargetInput(targetInputId, result) {
    const targetInput = document.querySelector(`[data-operation-id="${targetInputId}"]`)
    if (targetInput) {
      // Normalizza il numero: rimuovi zeri finali dopo la virgola (259,0 -> 259, 32,940 -> 32,94)
      let normalizedResult = result
      if (normalizedResult.includes(',')) {
        // Rimuovi zeri finali dopo la virgola
        normalizedResult = normalizedResult.replace(/,?0+$/, '')
        // Se rimane solo la virgola, rimuovila
        if (normalizedResult.endsWith(',')) {
          normalizedResult = normalizedResult.slice(0, -1)
        }
      }
      targetInput.value = normalizedResult
      // Trigger evento input per eventuali listener (es. exercise-checker)
      targetInput.dispatchEvent(new Event('input', { bubbles: true }))
      targetInput.dispatchEvent(new Event('change', { bubbles: true }))

      // Evidenzia brevemente l'input aggiornato
      targetInput.classList.add('ring-2', 'ring-green-500')
      setTimeout(() => {
        targetInput.classList.remove('ring-2', 'ring-green-500')
      }, 1000)
    }
  }
}
