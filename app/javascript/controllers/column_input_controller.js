import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "result"]

  connect() {
    // Aggiungi gli event listener a tutti gli input
    this.inputTargets.forEach((input, index) => {
      input.addEventListener('input', (e) => this.handleInput(e, index))
      input.addEventListener('keydown', (e) => this.handleKeydown(e, index))
    })

    // Aggiungi gli event listener per gli input del risultato (navigazione inversa)
    if (this.hasResultTarget) {
      this.resultTargets.forEach((input, index) => {
        input.addEventListener('input', (e) => this.handleResultInput(e, index))
        input.addEventListener('keydown', (e) => this.handleResultKeydown(e, index))
      })
    }
  }

  handleInput(event, currentIndex) {
    const input = event.target
    const value = input.value

    // Se l'utente ha digitato un carattere
    if (value.length === 1) {
      // Se è l'ultimo input, passa al primo risultato (unità)
      if (currentIndex === this.inputTargets.length - 1 && this.hasResultTarget) {
        this.resultTargets[this.resultTargets.length - 1].focus()
        this.resultTargets[this.resultTargets.length - 1].select()
      } 
      // Altrimenti passa all'input successivo
      else if (currentIndex < this.inputTargets.length - 1) {
        this.inputTargets[currentIndex + 1].focus()
        this.inputTargets[currentIndex + 1].select()
      }
    }
  }

  handleKeydown(event, currentIndex) {
    const input = event.target
    const columnsPerRow = 3

    // Backspace: vai all'input precedente se vuoto
    if (event.key === 'Backspace' && input.value === '' && currentIndex > 0) {
      event.preventDefault()
      this.inputTargets[currentIndex - 1].focus()
      this.inputTargets[currentIndex - 1].select()
    }

    // Freccia sinistra: vai a sinistra
    if (event.key === 'ArrowLeft' && input.selectionStart === 0) {
      event.preventDefault()
      if (currentIndex > 0) {
        this.inputTargets[currentIndex - 1].focus()
        this.inputTargets[currentIndex - 1].select()
      }
    }

    // Freccia destra: vai a destra
    if (event.key === 'ArrowRight' && input.selectionStart === input.value.length) {
      event.preventDefault()
      if (currentIndex < this.inputTargets.length - 1) {
        this.inputTargets[currentIndex + 1].focus()
        this.inputTargets[currentIndex + 1].select()
      }
    }

    // Freccia su: vai alla riga sopra
    if (event.key === 'ArrowUp') {
      event.preventDefault()
      const targetIndex = currentIndex - columnsPerRow
      if (targetIndex >= 0) {
        this.inputTargets[targetIndex].focus()
        this.inputTargets[targetIndex].select()
      }
    }

    // Freccia giù: vai alla riga sotto
    if (event.key === 'ArrowDown') {
      event.preventDefault()
      const targetIndex = currentIndex + columnsPerRow
      if (targetIndex < this.inputTargets.length) {
        this.inputTargets[targetIndex].focus()
        this.inputTargets[targetIndex].select()
      } else if (this.hasResultTarget) {
        // Se siamo nell'ultima riga di input, vai al risultato nella stessa colonna
        const columnIndex = currentIndex % columnsPerRow
        this.resultTargets[columnIndex].focus()
        this.resultTargets[columnIndex].select()
      }
    }
  }

  // Gestione per gli input del risultato (navigazione inversa: da destra a sinistra)
  handleResultInput(event, currentIndex) {
    const input = event.target
    const value = input.value

    // Se l'utente ha digitato un carattere e c'è un input precedente
    if (value.length === 1 && currentIndex > 0) {
      // Sposta il focus all'input precedente (da destra a sinistra)
      this.resultTargets[currentIndex - 1].focus()
      this.resultTargets[currentIndex - 1].select()
    }
  }

  handleResultKeydown(event, currentIndex) {
    const input = event.target
    const columnsPerRow = 3

    // Backspace: vai all'input successivo (destra) se vuoto
    if (event.key === 'Backspace' && input.value === '' && currentIndex < this.resultTargets.length - 1) {
      event.preventDefault()
      this.resultTargets[currentIndex + 1].focus()
      this.resultTargets[currentIndex + 1].select()
    }

    // Freccia destra: vai a destra
    if (event.key === 'ArrowRight' && input.selectionStart === input.value.length) {
      event.preventDefault()
      if (currentIndex < this.resultTargets.length - 1) {
        this.resultTargets[currentIndex + 1].focus()
        this.resultTargets[currentIndex + 1].select()
      }
    }

    // Freccia sinistra: vai a sinistra
    if (event.key === 'ArrowLeft' && input.selectionStart === 0) {
      event.preventDefault()
      if (currentIndex > 0) {
        this.resultTargets[currentIndex - 1].focus()
        this.resultTargets[currentIndex - 1].select()
      }
    }

    // Freccia su: vai alla riga sopra (ultimo input)
    if (event.key === 'ArrowUp') {
      event.preventDefault()
      const columnIndex = currentIndex
      const targetIndex = this.inputTargets.length - columnsPerRow + columnIndex
      if (targetIndex >= 0 && targetIndex < this.inputTargets.length) {
        this.inputTargets[targetIndex].focus()
        this.inputTargets[targetIndex].select()
      }
    }

    // Freccia giù: non fa nulla (siamo già nell'ultima riga)
    if (event.key === 'ArrowDown') {
      event.preventDefault()
    }
  }
}

