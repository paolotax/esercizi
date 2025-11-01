import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "title", "grid"]

  open(event) {
    event.preventDefault()
    
    // Ottieni i dati dall'elemento cliccato
    const button = event.currentTarget
    this.currentButton = button  // Salva riferimento al bottone per dopo
    
    const num1 = button.dataset.num1
    const num2 = button.dataset.num2
    const title = button.dataset.title || `${num1} + ${num2} =`
    
    // Aggiorna il titolo del modal
    this.titleTarget.textContent = title
    
    // Calcola il risultato corretto
    const result = parseInt(num1) + parseInt(num2)
    this.correctResult = result
    
    // Prepara i dati per la griglia
    const digits1 = this.getDigits(num1)
    const digits2 = this.getDigits(num2)
    const resultDigits = this.getDigits(result.toString())
    
    // Aggiorna la griglia
    this.updateGrid(digits1, digits2, resultDigits)
    
    // Carica eventuale risultato salvato
    if (button.dataset.savedResult) {
      this.loadSavedResult(button.dataset.savedResult)
    }
    
    // Mostra il modal
    this.modalTarget.classList.remove("hidden")
    this.modalTarget.classList.add("flex")
    
    // Focus sul primo input
    setTimeout(() => {
      const firstInput = this.gridTarget.querySelector('input')
      if (firstInput) firstInput.focus()
    }, 100)
  }

  close() {
    this.modalTarget.classList.add("hidden")
    this.modalTarget.classList.remove("flex")
    
    // Reset degli input
    this.gridTarget.querySelectorAll('input').forEach(input => {
      input.value = ''
      input.classList.remove('bg-green-100', 'bg-red-100')
    })
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  getDigits(num) {
    // Riempie con zeri a sinistra fino a 4 cifre
    const padded = num.toString().padStart(4, '0')
    return [padded[0], padded[1], padded[2], padded[3]]
  }

  updateGrid(digits1, digits2, resultDigits) {
    const inputs = this.gridTarget.querySelectorAll('input')
    
    // Input riga 1 (primo addendo) - 4 cifre
    inputs[0].dataset.correctAnswer = digits1[0]
    inputs[1].dataset.correctAnswer = digits1[1]
    inputs[2].dataset.correctAnswer = digits1[2]
    inputs[3].dataset.correctAnswer = digits1[3]
    
    // Input riga 2 (secondo addendo) - 4 cifre
    inputs[4].dataset.correctAnswer = digits2[0]
    inputs[5].dataset.correctAnswer = digits2[1]
    inputs[6].dataset.correctAnswer = digits2[2]
    inputs[7].dataset.correctAnswer = digits2[3]
    
    // Input riga 3 (risultato) - 4 cifre
    inputs[8].dataset.correctAnswer = resultDigits[0]
    inputs[9].dataset.correctAnswer = resultDigits[1]
    inputs[10].dataset.correctAnswer = resultDigits[2]
    inputs[11].dataset.correctAnswer = resultDigits[3]
  }

  handleEscape(event) {
    if (event.key === 'Escape') {
      this.close()
    }
  }

  save() {
    // Leggi il risultato inserito dagli input
    const resultInputs = this.gridTarget.querySelectorAll('input[data-column-input-target="result"]')
    let userResult = ''
    
    resultInputs.forEach(input => {
      userResult += input.value || '0'
    })
    
    // Rimuovi gli zeri a sinistra
    userResult = parseInt(userResult).toString()
    
    // Verifica se è corretto
    const isCorrect = parseInt(userResult) === this.correctResult
    
    // Salva nel bottone
    if (this.currentButton) {
      this.currentButton.dataset.savedResult = userResult
      
      // Aggiorna il testo del bottone per mostrare il risultato
      const operationText = this.currentButton.textContent.split('=')[0] + '= '
      this.currentButton.innerHTML = `
        ${operationText}
        <span class="${isCorrect ? 'text-green-600 font-bold' : 'text-red-600 font-bold'}">${userResult}</span>
        ${isCorrect ? '✓' : '✗'}
      `
      
      // Aggiungi una classe per indicare che è stato salvato
      this.currentButton.classList.add(isCorrect ? 'bg-green-50' : 'bg-red-50')
    }
    
    // Chiudi il modal
    this.close()
  }

  loadSavedResult(savedResult) {
    // Carica il risultato salvato negli input
    const resultInputs = this.gridTarget.querySelectorAll('input[data-column-input-target="result"]')
    const digits = this.getDigits(savedResult)
    
    resultInputs.forEach((input, index) => {
      if (digits[index]) {
        input.value = digits[index]
      }
    })
  }
}

