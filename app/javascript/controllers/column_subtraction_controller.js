import { Controller } from "@hotwired/stimulus"

// Controller specifico per le sottrazioni in colonna
// Estende le funzionalità base con logica specifica per i prestiti
export default class extends Controller {
  static targets = ["input", "result", "carry"]

  connect() {
    // Aggiungi gli event listener per i prestiti (carry)
    if (this.hasCarryTarget) {
      this.carryTargets.forEach((input, index) => {
        input.addEventListener('input', (e) => this.handleCarryInput(e, index))
        input.addEventListener('keydown', (e) => this.handleCarryKeydown(e, index))
      })
    }

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
    // Per le sottrazioni: 2 righe (minuendo + sottraendo) x numero colonne
    const numColumns = this.inputTargets.length / 2

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
      const targetIndex = currentIndex - numColumns
      if (targetIndex >= 0) {
        this.inputTargets[targetIndex].focus()
        this.inputTargets[targetIndex].select()
      } else if (this.hasCarryTarget) {
        // Se siamo nella prima riga di input (minuendo), vai ai carry
        const columnIndex = currentIndex % numColumns
        if (columnIndex < this.carryTargets.length) {
          this.carryTargets[columnIndex].focus()
          this.carryTargets[columnIndex].select()
        }
      }
    }

    // Freccia giù: vai alla riga sotto
    if (event.key === 'ArrowDown') {
      event.preventDefault()
      const targetIndex = currentIndex + numColumns
      if (targetIndex < this.inputTargets.length) {
        this.inputTargets[targetIndex].focus()
        this.inputTargets[targetIndex].select()
      } else if (this.hasResultTarget) {
        // Se siamo nell'ultima riga di input, vai al risultato
        const columnIndex = currentIndex % numColumns
        if (columnIndex < this.resultTargets.length) {
          this.resultTargets[columnIndex].focus()
          this.resultTargets[columnIndex].select()
        }
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
    const columnsPerRow = this.resultTargets.length

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

    // Freccia su: vai all'ultima riga di input (sottraendo)
    if (event.key === 'ArrowUp') {
      event.preventDefault()
      const columnIndex = currentIndex
      const numColumns = this.inputTargets.length / 2
      const targetIndex = numColumns + columnIndex // Seconda riga di input
      if (targetIndex < this.inputTargets.length) {
        this.inputTargets[targetIndex].focus()
        this.inputTargets[targetIndex].select()
      }
    }

    // Freccia giù: non fa nulla (siamo già nell'ultima riga)
    if (event.key === 'ArrowDown') {
      event.preventDefault()
    }
  }

  // Gestione SPECIFICA per le sottrazioni: quando scrivo nel carry, barro il numero sotto
  handleCarryInput(event, currentIndex) {
    const input = event.target
    const value = input.value

    // Quando scrivo un numero nel carry (prestito)
    if (value.length >= 1) {
      // Trova la cifra del minuendo corrispondente (stessa colonna, prima riga di input)
      const minuendInput = this.inputTargets[currentIndex]
      if (minuendInput) {
        // Applica il line-through (X rossa)
        minuendInput.classList.add('line-through')
      }

      // Passa al carry successivo se esiste
      if (currentIndex < this.carryTargets.length - 1) {
        this.carryTargets[currentIndex + 1].focus()
        this.carryTargets[currentIndex + 1].select()
      }
    }
  }

  handleCarryKeydown(event, currentIndex) {
    const input = event.target

    // Backspace: rimuovi il line-through e vai al carry precedente
    if (event.key === 'Backspace') {
      if (input.value === '') {
        // Se la cella è vuota, vai al precedente
        event.preventDefault()
        if (currentIndex > 0) {
          this.carryTargets[currentIndex - 1].focus()
          this.carryTargets[currentIndex - 1].select()
        }
      } else {
        // Se sto cancellando, rimuovi il line-through dalla cifra sotto
        const minuendInput = this.inputTargets[currentIndex]
        if (minuendInput) {
          minuendInput.classList.remove('line-through')
        }
      }
    }

    // Freccia sinistra: vai a sinistra
    if (event.key === 'ArrowLeft' && input.selectionStart === 0) {
      event.preventDefault()
      if (currentIndex > 0) {
        this.carryTargets[currentIndex - 1].focus()
        this.carryTargets[currentIndex - 1].select()
      }
    }

    // Freccia destra: vai a destra
    if (event.key === 'ArrowRight' && input.selectionStart === input.value.length) {
      event.preventDefault()
      if (currentIndex < this.carryTargets.length - 1) {
        this.carryTargets[currentIndex + 1].focus()
        this.carryTargets[currentIndex + 1].select()
      }
    }

    // Freccia giù: vai al minuendo nella stessa colonna
    if (event.key === 'ArrowDown') {
      event.preventDefault()
      if (currentIndex < this.inputTargets.length) {
        this.inputTargets[currentIndex].focus()
        this.inputTargets[currentIndex].select()
      }
    }

    // Freccia su: non fa nulla (siamo già nella prima riga)
    if (event.key === 'ArrowUp') {
      event.preventDefault()
    }
  }
}
