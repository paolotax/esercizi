import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "title", "grid"]

  async open(event) {
    event.preventDefault()
    
    // Ottieni i dati dall'elemento cliccato
    const button = event.currentTarget
    this.currentButton = button
    
    const num1 = button.dataset.num1
    const num2 = button.dataset.num2
    const operation = `${num1} + ${num2}`
    const title = button.dataset.title || `${operation} =`
    
    // Salva i numeri per il calcolo del risultato corretto
    this.correctResult = parseInt(num1) + parseInt(num2)
    
    // Aggiorna il titolo del modal
    this.titleTarget.textContent = title
    
    // Mostra il modal con loading
    this.modalTarget.classList.remove("hidden")
    this.modalTarget.classList.add("flex")
    this.gridTarget.innerHTML = '<div class="text-center py-8">Caricamento...</div>'
    
    try {
      // Fetch del contenuto dinamico
      const response = await fetch(`/exercises/column_addition_grid?operation=${encodeURIComponent(operation)}`)
      const html = await response.text()
      
      // Inserisci il contenuto nel grid
      this.gridTarget.innerHTML = html
      
      // Focus sul primo input degli addendi (non carry)
      setTimeout(() => {
        const firstInput = this.gridTarget.querySelector('input[data-column-input-target="input"]')
        if (firstInput) {
          firstInput.focus()
          firstInput.select()
        }
      }, 100)
      
    } catch (error) {
      console.error('Errore nel caricamento della griglia:', error)
      this.gridTarget.innerHTML = '<div class="text-center text-red-500 py-8">Errore nel caricamento</div>'
    }
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
}

