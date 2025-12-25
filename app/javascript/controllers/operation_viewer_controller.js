import { Controller } from "@hotwired/stimulus"

/**
 * Controller unificato per visualizzare operazioni in colonna
 * Supporta:
 * - Display: sidebar (default) o modal
 * - Layout: quaderno (default) o column
 * - Operazioni: addizione, sottrazione, moltiplicazione, divisione
 * - Singola operazione o gruppi
 */
export default class extends Controller {
  static targets = ["sidebar", "modal", "backdrop", "title", "content"]

  connect() {
    this.boundHandleEscape = this.handleEscape.bind(this)
    document.addEventListener('keydown', this.boundHandleEscape)
  }

  disconnect() {
    document.removeEventListener('keydown', this.boundHandleEscape)
  }

  handleEscape(event) {
    if (event.key === 'Escape') {
      this.close()
    }
  }

  // =============================================
  // APERTURA SINGOLA OPERAZIONE
  // =============================================
  async open(event) {
    event.preventDefault()
    const button = event.currentTarget

    // Estrai dati dal bottone
    this.targetInputId = button.dataset.targetInput
    this.operation = button.dataset.operation
    this.operationType = button.dataset.type || this.detectOperationType(this.operation)
    this.layout = button.dataset.layout || 'quaderno'
    this.displayMode = button.dataset.display || 'sidebar'
    this.isGroup = false

    // Titolo
    this.setTitle(this.operationType)

    // Mostra container
    this.showContainer()

    // Fetch operazione
    await this.fetchOperation(this.operation, this.operationType, this.layout)
  }

  // =============================================
  // APERTURA GRUPPO DI OPERAZIONI
  // =============================================
  async openGroup(event) {
    event.preventDefault()
    const button = event.currentTarget

    // Estrai dati dal bottone
    this.operationsData = JSON.parse(button.dataset.operations || '[]')
    this.operationType = button.dataset.type || 'addizione'
    this.layout = button.dataset.layout || 'quaderno'
    this.displayMode = button.dataset.display || 'sidebar'
    this.groupLetter = button.dataset.group || ''
    this.isGroup = true
    this.currentGroupButton = button

    // Opzioni extra
    this.showCarry = button.dataset.showCarry === 'true'
    this.showBorrow = button.dataset.showBorrow === 'true'
    this.withProof = button.dataset.withProof === 'true'
    this.showOperands = button.dataset.showOperands !== 'false'

    // Salva risultati precedenti per ripristino
    this.savedResults = button.dataset.savedResults ? JSON.parse(button.dataset.savedResults) : {}

    // Titolo
    this.setTitle(this.operationType, true, this.groupLetter)

    // Mostra container
    this.showContainer()

    // Fetch tutte le operazioni
    await this.fetchGroupOperations()
  }

  // =============================================
  // FETCH OPERAZIONI
  // =============================================
  async fetchOperation(operation, type, layout) {
    this.showLoading()

    try {
      const url = `/exercises/operation_grid?operations=${encodeURIComponent(operation)}&type=${type}&layout=${layout}`
      const response = await fetch(url)

      if (!response.ok) {
        throw new Error('Errore nel caricamento')
      }

      this.contentTarget.innerHTML = await response.text()
      this.focusFirstInput()

    } catch (error) {
      console.error('Errore nel caricamento:', error)
      this.showError()
    }
  }

  async fetchGroupOperations() {
    this.showLoading()

    try {
      const htmlParts = []

      for (const op of this.operationsData) {
        let url = `/exercises/operation_grid?operations=${encodeURIComponent(op.operation)}&type=${this.operationType}&layout=${this.layout}`

        // Aggiungi opzioni extra
        if (op.showPartialCarries || this.showCarry) {
          url += '&show_carry=true'
        }
        if (this.showBorrow) {
          url += '&show_borrow=true'
        }
        if (!this.showOperands) {
          url += '&show_operands=false'
        }

        const response = await fetch(url)
        if (!response.ok) {
          throw new Error('Errore nel caricamento')
        }

        const html = await response.text()
        htmlParts.push(`<div class="quaderno-group-item mb-4" data-target-input="${op.targetId}" data-operation-index="${htmlParts.length}">${html}</div>`)
      }

      this.contentTarget.innerHTML = `<div class="flex flex-col items-center gap-2">${htmlParts.join('')}</div>`

      // Ripristina risultati salvati
      this.restoreSavedResults()

      this.focusFirstInput()

    } catch (error) {
      console.error('Errore nel caricamento:', error)
      this.showError()
    }
  }

  // =============================================
  // DISPLAY MANAGEMENT
  // =============================================
  showContainer() {
    if (this.displayMode === 'modal' && this.hasModalTarget) {
      this.modalTarget.classList.remove('hidden')
      this.modalTarget.classList.add('flex')
    } else if (this.hasSidebarTarget && this.hasBackdropTarget) {
      this.backdropTarget.classList.remove('hidden')
      requestAnimationFrame(() => {
        this.sidebarTarget.classList.remove('translate-x-full')
      })
    }
  }

  hideContainer() {
    if (this.displayMode === 'modal' && this.hasModalTarget) {
      this.modalTarget.classList.add('hidden')
      this.modalTarget.classList.remove('flex')
    } else if (this.hasSidebarTarget && this.hasBackdropTarget) {
      this.sidebarTarget.classList.add('translate-x-full')
      setTimeout(() => {
        this.backdropTarget.classList.add('hidden')
        this.contentTarget.innerHTML = ''
      }, 300)
    }
  }

  close() {
    this.hideContainer()
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget || event.target === this.backdropTarget) {
      this.close()
    }
  }

  // =============================================
  // SALVATAGGIO RISULTATI
  // =============================================
  save() {
    if (this.isGroup) {
      this.saveGroup()
    } else {
      this.saveSingle()
    }
    this.close()
  }

  saveSingle() {
    const result = this.extractResult(this.contentTarget, this.operationType)

    if (this.targetInputId && result) {
      this.updateTargetInput(this.targetInputId, result)
    }
  }

  saveGroup() {
    const groupItems = this.contentTarget.querySelectorAll('.quaderno-group-item')
    const results = []
    const savedResults = {}

    groupItems.forEach((item, idx) => {
      const targetInputId = item.dataset.targetInput
      const result = this.extractResult(item, this.operationType)

      // Salva per ripristino
      if (result) {
        savedResults[idx] = result
      }

      // Salva nell'input target
      if (targetInputId && result) {
        this.updateTargetInput(targetInputId, result)
      }

      results.push({
        index: idx,
        result: result,
        targetInputId: targetInputId
      })
    })

    // Salva risultati nel dataset del bottone per ripristino
    if (this.currentGroupButton) {
      this.currentGroupButton.dataset.savedResults = JSON.stringify(savedResults)
    }

    // Aggiorna visualizzazione bottone gruppo
    this.updateGroupButtonState(results)
  }

  // =============================================
  // ESTRAZIONE RISULTATI
  // =============================================
  extractResult(container, operationType) {
    let result = ''

    switch (operationType) {
      case 'addizione':
      case 'sottrazione':
        result = this.extractResultWithComma(
          container,
          'input[data-quaderno-target="result"]',
          'input[data-quaderno-target="comma"][data-row-type="result"]'
        )
        break
      case 'moltiplicazione':
        result = this.extractResultWithCommaSpot(
          container,
          'input[data-quaderno-target="result"]',
          '[data-quaderno-target="commaSpot"].active'
        )
        break
      case 'divisione':
        result = this.extractResultWithCommaSpot(
          container,
          'input[data-quaderno-target="quotient"]',
          '[data-quaderno-target="commaSpot"].active'
        )
        break
    }

    // Pulisci risultato
    result = result.replace(/^\s+/, '').replace(/^0+(?=\d)/, '')

    return result
  }

  extractResultWithComma(container, resultSelector, commaSelector) {
    const resultInputs = container.querySelectorAll(resultSelector)
    const commaInput = container.querySelector(commaSelector)

    let commaPosition = -1
    if (commaInput) {
      const grid = container.querySelector('.inline-grid')
      if (grid) {
        const allDivs = Array.from(grid.children)
        const commaParent = commaInput.parentElement
        const commaGridIndex = allDivs.indexOf(commaParent)

        let countBefore = 0
        resultInputs.forEach(input => {
          const inputParent = input.parentElement
          const inputGridIndex = allDivs.indexOf(inputParent)
          if (inputGridIndex < commaGridIndex) {
            countBefore++
          }
        })
        commaPosition = countBefore
      }
    }

    let result = ''
    resultInputs.forEach((input, idx) => {
      if (commaPosition !== -1 && idx === commaPosition) {
        const commaValue = commaInput ? commaInput.value : ''
        if (commaValue === ',') {
          result += ','
        }
      }
      result += input.value || ''
    })

    return result
  }

  extractResultWithCommaSpot(container, resultSelector, commaSpotSelector) {
    const resultInputs = container.querySelectorAll(resultSelector)

    let result = ''
    resultInputs.forEach(input => {
      result += input.value || ''
    })

    const activeComma = container.querySelector(commaSpotSelector)
    if (activeComma) {
      const decimalPlaces = parseInt(activeComma.dataset.position) || 0
      if (decimalPlaces > 0 && result.length > decimalPlaces) {
        const integerPart = result.slice(0, result.length - decimalPlaces)
        const decimalPart = result.slice(result.length - decimalPlaces)
        result = integerPart + ',' + decimalPart
      }
    }

    return result
  }

  // =============================================
  // RIPRISTINO RISULTATI
  // =============================================
  restoreSavedResults() {
    if (!this.savedResults || Object.keys(this.savedResults).length === 0) return

    const groupItems = this.contentTarget.querySelectorAll('.quaderno-group-item')

    groupItems.forEach((item, idx) => {
      const savedValue = this.savedResults[idx]
      if (!savedValue) return

      // Trova gli input del risultato
      let resultInputs = item.querySelectorAll('input[data-quaderno-target="result"]')
      if (resultInputs.length === 0) {
        resultInputs = item.querySelectorAll('input[data-quaderno-target="quotient"]')
      }

      // Ripristina i digit da destra a sinistra
      const digits = savedValue.replace(',', '').split('')
      const startIdx = resultInputs.length - digits.length

      digits.forEach((digit, digitIdx) => {
        const inputIdx = startIdx + digitIdx
        if (inputIdx >= 0 && resultInputs[inputIdx]) {
          resultInputs[inputIdx].value = digit
        }
      })
    })
  }

  // =============================================
  // AGGIORNAMENTO TARGET INPUT
  // =============================================
  updateTargetInput(targetInputId, result) {
    const targetInput = document.querySelector(`[data-operation-id="${targetInputId}"]`)
    if (!targetInput) return

    // Normalizza il numero
    let normalizedResult = result
    if (normalizedResult.includes(',')) {
      normalizedResult = normalizedResult.replace(/,?0+$/, '')
      if (normalizedResult.endsWith(',')) {
        normalizedResult = normalizedResult.slice(0, -1)
      }
    }

    targetInput.value = normalizedResult

    // Trigger eventi
    targetInput.dispatchEvent(new Event('input', { bubbles: true }))
    targetInput.dispatchEvent(new Event('change', { bubbles: true }))

    // Evidenzia brevemente
    targetInput.classList.add('ring-2', 'ring-green-500')
    setTimeout(() => {
      targetInput.classList.remove('ring-2', 'ring-green-500')
    }, 1000)
  }

  updateGroupButtonState(results) {
    if (!this.currentGroupButton) return

    const anyAnswered = results.some(r => r.result)

    if (anyAnswered) {
      this.currentGroupButton.classList.remove('border-transparent')
      this.currentGroupButton.classList.add('border-green-500', 'bg-green-50', 'dark:bg-green-900/20')
    }
  }

  // =============================================
  // UTILITY
  // =============================================
  detectOperationType(operation) {
    if (operation.match(/[÷:\/]/)) {
      return 'divisione'
    } else if (operation.match(/[x×*]/i)) {
      return 'moltiplicazione'
    } else if (operation.includes('-')) {
      return 'sottrazione'
    } else {
      return 'addizione'
    }
  }

  setTitle(operationType, isGroup = false, groupLetter = '') {
    if (!this.hasTitleTarget) return

    const titles = {
      'addizione': isGroup ? 'Addizioni in colonna' : 'Addizione in colonna',
      'sottrazione': isGroup ? 'Sottrazioni in colonna' : 'Sottrazione in colonna',
      'moltiplicazione': isGroup ? 'Moltiplicazioni in colonna' : 'Moltiplicazione in colonna',
      'divisione': isGroup ? 'Divisioni in colonna' : 'Divisione in colonna'
    }

    let title = titles[operationType] || 'Operazione in colonna'
    if (isGroup && groupLetter) {
      title += ` - Gruppo ${groupLetter}`
    }

    this.titleTarget.textContent = title
  }

  showLoading() {
    this.contentTarget.innerHTML = '<div class="text-center py-8 text-gray-500 dark:text-gray-400">Caricamento...</div>'
  }

  showError() {
    this.contentTarget.innerHTML = '<div class="text-center py-8 text-red-500">Errore nel caricamento</div>'
  }

  focusFirstInput() {
    setTimeout(() => {
      const firstInput = this.contentTarget.querySelector('input:not([readonly]):not([disabled])')
      if (firstInput) {
        firstInput.focus()
        firstInput.select()
      }
    }, 150)
  }
}
