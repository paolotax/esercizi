import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "title", "grid", "groupButton", "operationsList"]

  // Apre il modal per un gruppo di operazioni
  async openGroup(event) {
    event.preventDefault()

    const button = event.currentTarget
    this.currentGroupButton = button
    this.currentGroup = button.dataset.group
    const operations = button.dataset.operations
    const showCarry = button.dataset.showCarry === "true"
    const showBorrow = button.dataset.showBorrow === "true"
    const withProof = button.dataset.withProof === "true"
    // showOperands: se false, minuendo/sottraendo sono vuoti
    const showOperands = button.dataset.showOperands !== "false"

    // Determina il tipo di operazione (addizione o sottrazione)
    this.operationType = operations.includes('-') ? 'subtraction' : 'addition'

    // Carica i risultati salvati (se esistono)
    this.savedResults = button.dataset.savedResults ? JSON.parse(button.dataset.savedResults) : {}
    this.showCarry = showCarry
    this.showBorrow = showBorrow
    this.withProof = withProof
    this.showOperands = showOperands

    // Calcola i risultati corretti per ogni operazione
    this.correctResults = operations.split(',').map(op => {
      if (this.operationType === 'subtraction') {
        const parts = op.split('-')
        return parseInt(parts[0]) - parseInt(parts[1])
      } else {
        const parts = op.split('+')
        return parseInt(parts[0]) + parseInt(parts[1])
      }
    })

    // Aggiorna il titolo del modal
    let opName = this.operationType === 'subtraction' ? 'Sottrazioni' : 'Addizioni'
    if (withProof) opName += ' con prova'
    this.titleTarget.textContent = `Gruppo ${this.currentGroup.toUpperCase()} - ${opName} in colonna`

    // Mostra il modal con loading
    this.modalTarget.classList.remove("hidden")
    this.modalTarget.classList.add("flex")
    this.gridTarget.innerHTML = '<div class="text-center py-8">Caricamento...</div>'

    try {
      // Fetch del contenuto dinamico - usa sempre l'endpoint unificato
      const url = `/exercises/column_operations_grid?operations=${encodeURIComponent(operations)}&with_proof=${withProof}&show_carry=${showCarry}&show_borrow=${showBorrow}&show_operands=${showOperands}`
      const response = await fetch(url)
      const html = await response.text()

      // Inserisci il contenuto nel grid
      this.gridTarget.innerHTML = html

      // Ripristina i risultati salvati
      this.restoreSavedResults()

      // Focus sul primo input vuoto del risultato
      setTimeout(() => {
        // Per le operazioni con prova, cerca entrambi i tipi di input
        let targetSelector
        if (withProof) {
          targetSelector = 'input[data-column-subtraction-target="result"], input[data-column-addition-target="result"]'
        } else if (this.operationType === 'subtraction') {
          targetSelector = 'input[data-column-subtraction-target="result"]'
        } else {
          targetSelector = 'input[data-column-addition-target="result"]'
        }
        const emptyInput = this.gridTarget.querySelector(`${targetSelector}:not([value])`)
        const firstInput = emptyInput || this.gridTarget.querySelector(targetSelector)
        if (firstInput) {
          firstInput.focus()
        }
      }, 100)

    } catch (error) {
      console.error('Errore nel caricamento delle griglie:', error)
      this.gridTarget.innerHTML = '<div class="text-center text-red-500 py-8">Errore nel caricamento</div>'
    }
  }

  // Ripristina i risultati salvati nelle griglie
  restoreSavedResults() {
    if (!this.savedResults) return

    const operationItems = this.gridTarget.querySelectorAll('.operation-item')
    const targetSelector = this.operationType === 'subtraction'
      ? 'input[data-column-subtraction-target="result"]'
      : 'input[data-column-addition-target="result"]'

    operationItems.forEach((item, idx) => {
      const savedDigits = this.savedResults[idx]
      if (!savedDigits) return

      const resultInputs = item.querySelectorAll(targetSelector)

      // I digit sono salvati come array, li ripristiniamo da destra a sinistra
      const digitsArray = savedDigits.split('')
      const startIdx = resultInputs.length - digitsArray.length

      digitsArray.forEach((digit, digitIdx) => {
        const inputIdx = startIdx + digitIdx
        if (inputIdx >= 0 && resultInputs[inputIdx]) {
          resultInputs[inputIdx].value = digit
        }
      })
    })
  }

  close() {
    this.modalTarget.classList.add("hidden")
    this.modalTarget.classList.remove("flex")
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  handleEscape(event) {
    if (event.key === 'Escape') {
      this.close()
    }
  }

  // Salva tutti i risultati del gruppo
  saveGroup() {
    const operationItems = this.gridTarget.querySelectorAll('.operation-item')
    const results = []
    const savedResults = {}

    operationItems.forEach((item, idx) => {
      // Per le operazioni con prova, leggi i risultati dalla main-operation
      // Per operazioni singole, leggi direttamente
      let targetElement = item
      if (this.withProof) {
        targetElement = item.querySelector('.main-operation') || item
      }

      // Cerca prima sottrazioni, poi addizioni
      let resultInputs = targetElement.querySelectorAll('input[data-column-subtraction-target="result"]')
      if (resultInputs.length === 0) {
        resultInputs = targetElement.querySelectorAll('input[data-column-addition-target="result"]')
      }

      let userResult = ''
      resultInputs.forEach(input => {
        userResult += input.value || ''
      })

      // Rimuovi gli spazi vuoti a sinistra e converti
      userResult = userResult.replace(/^\s+/, '')
      const numericResult = userResult === '' ? null : parseInt(userResult)

      // Salva i digit per il ripristino (solo se c'è un valore)
      if (userResult !== '') {
        savedResults[idx] = userResult
      }

      // Verifica se è corretto
      const isCorrect = numericResult === this.correctResults[idx]

      results.push({
        index: idx,
        userResult: numericResult,
        correctResult: this.correctResults[idx],
        isCorrect: isCorrect
      })
    })

    // Salva i risultati nel dataset del bottone per il ripristino
    if (this.currentGroupButton) {
      this.currentGroupButton.dataset.savedResults = JSON.stringify(savedResults)
    }

    // Aggiorna la visualizzazione nella pagina principale
    this.updateMainPageResults(results)

    // Chiudi il modal
    this.close()
  }

  // Aggiorna i risultati nella pagina principale
  updateMainPageResults(results) {
    // Trova la lista delle operazioni per questo gruppo
    const operationsList = this.element.querySelector(`[data-column-modal-target="operationsList"][data-group="${this.currentGroup}"]`)

    if (!operationsList) return

    const operationItems = operationsList.querySelectorAll('.operation-item')

    results.forEach((result, idx) => {
      const item = operationItems[idx]
      if (!item) return

      // Ottieni il testo originale dell'operazione (es. "216 + 372 =")
      const originalText = item.textContent.split('=')[0] + '= '

      if (result.userResult !== null) {
        // Aggiorna il contenuto con il risultato
        item.innerHTML = `
          ${originalText}
          <span class="${result.isCorrect ? 'text-green-600 font-bold' : 'text-red-600 font-bold'}">${result.userResult}</span>
          ${result.isCorrect ? '<span class="text-green-600 ml-1">✓</span>' : '<span class="text-red-600 ml-1">✗</span>'}
        `
      }
    })

    // Aggiungi una classe al gruppo per indicare che è stato completato
    if (this.currentGroupButton) {
      const allCorrect = results.every(r => r.isCorrect)
      const anyAnswered = results.some(r => r.userResult !== null)

      if (anyAnswered) {
        this.currentGroupButton.classList.remove('border-transparent')
        if (allCorrect) {
          this.currentGroupButton.classList.add('border-green-500', 'bg-green-50')
        } else {
          this.currentGroupButton.classList.add('border-orange-400', 'bg-orange-50')
        }
      }
    }
  }

  // Mantieni compatibilità con il vecchio metodo open (per singola operazione)
  async open(event) {
    event.preventDefault()

    const button = event.currentTarget
    this.currentButton = button

    const num1 = button.dataset.num1
    const num2 = button.dataset.num2
    const operation = `${num1} + ${num2}`
    const title = button.dataset.title || `${operation} =`

    this.correctResult = parseInt(num1) + parseInt(num2)

    this.titleTarget.textContent = title

    this.modalTarget.classList.remove("hidden")
    this.modalTarget.classList.add("flex")
    this.gridTarget.innerHTML = '<div class="text-center py-8">Caricamento...</div>'

    try {
      const response = await fetch(`/exercises/column_addition_grid?operations=${encodeURIComponent(operation)}`)
      const html = await response.text()

      this.gridTarget.innerHTML = html

      setTimeout(() => {
        const firstInput = this.gridTarget.querySelector('input[data-column-addition-target="result"]')
        if (firstInput) {
          firstInput.focus()
        }
      }, 100)

    } catch (error) {
      console.error('Errore nel caricamento della griglia:', error)
      this.gridTarget.innerHTML = '<div class="text-center text-red-500 py-8">Errore nel caricamento</div>'
    }
  }

  // Salva singola operazione (mantieni compatibilità)
  save() {
    const resultInputs = this.gridTarget.querySelectorAll('input[data-column-addition-target="result"]')
    let userResult = ''

    resultInputs.forEach(input => {
      userResult += input.value || '0'
    })

    userResult = parseInt(userResult).toString()

    const isCorrect = parseInt(userResult) === this.correctResult

    if (this.currentButton) {
      this.currentButton.dataset.savedResult = userResult

      const operationText = this.currentButton.textContent.split('=')[0] + '= '
      this.currentButton.innerHTML = `
        ${operationText}
        <span class="${isCorrect ? 'text-green-600 font-bold' : 'text-red-600 font-bold'}">${userResult}</span>
        ${isCorrect ? '✓' : '✗'}
      `

      this.currentButton.classList.add(isCorrect ? 'bg-green-50' : 'bg-red-50')
    }

    this.close()
  }
}
