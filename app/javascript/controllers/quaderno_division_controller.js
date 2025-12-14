import { Controller } from "@hotwired/stimulus"
import JSConfetti from "js-confetti"

/**
 * Controller per il quaderno di divisioni in colonna
 * Gestisce la navigazione tra celle, verifica delle risposte e feedback visivo
 */
export default class extends Controller {
  static targets = ["dividend", "divisor", "quotient", "product", "remainder", "bringdown", "cell", "commaSpot", "commaShift", "extraZero"]

  connect() {
    this.jsConfetti = new JSConfetti()

    // Aggiungi event listener per la navigazione
    this.addNavigationListeners()

    // Aggiungi listener per navigazione keyboard sui commaSpot
    if (this.hasCommaSpotTarget) {
      this.commaSpotTargets.forEach(spot => {
        spot.addEventListener('keydown', (e) => this.handleCommaSpotKeydown(e, spot))
      })
    }
  }

  addNavigationListeners() {
    const allInputs = this.element.querySelectorAll('input[type="text"]')

    allInputs.forEach((input, index) => {
      input.addEventListener('input', (e) => this.handleInput(e, index, allInputs))
      input.addEventListener('keydown', (e) => this.handleKeydown(e, index, allInputs))
    })
  }

  handleInput(event, currentIndex, allInputs) {
    const input = event.target
    const value = input.value

    // Se l'utente ha inserito un carattere, passa alla cella successiva
    if (value.length === 1 && currentIndex < allInputs.length - 1) {
      allInputs[currentIndex + 1].focus()
      allInputs[currentIndex + 1].select()
    }
  }

  handleKeydown(event, currentIndex, allInputs) {
    const currentInput = event.target

    switch (event.key) {
      case 'Backspace':
        if (currentInput.value === '' && currentIndex > 0) {
          event.preventDefault()
          allInputs[currentIndex - 1].focus()
          allInputs[currentIndex - 1].select()
        }
        break

      case 'ArrowLeft':
        event.preventDefault()
        if (currentIndex > 0) {
          allInputs[currentIndex - 1].focus()
          allInputs[currentIndex - 1].select()
        }
        break

      case 'ArrowRight':
        event.preventDefault()
        if (currentIndex < allInputs.length - 1) {
          allInputs[currentIndex + 1].focus()
          allInputs[currentIndex + 1].select()
        }
        break

      case 'ArrowUp':
        event.preventDefault()
        this.navigateVertical(currentInput, -1)
        break

      case 'ArrowDown':
        event.preventDefault()
        this.navigateVertical(currentInput, 1)
        break
    }
  }

  navigateVertical(currentInput, direction) {
    const currentRow = parseInt(currentInput.dataset.row)
    const currentCol = parseInt(currentInput.dataset.col)

    if (isNaN(currentRow) || isNaN(currentCol)) return

    const targetRow = currentRow + direction
    const target = this.element.querySelector(
      `input[data-row="${targetRow}"][data-col="${currentCol}"]`
    )

    if (target) {
      target.focus()
      target.select()
    }
  }

  // === Comma Actions ===

  // Toggle virgola nel quoziente
  toggleComma(event) {
    const spot = event.currentTarget

    // Se questo spot è già attivo, disattivalo
    if (spot.classList.contains('active')) {
      spot.classList.remove('active')
      return
    }

    // Disattiva tutti gli altri spot (solo una virgola alla volta)
    if (this.hasCommaSpotTarget) {
      this.commaSpotTargets.forEach(s => {
        s.classList.remove('active', 'correct', 'incorrect', 'missing')
      })
    }

    // Attiva questo spot
    spot.classList.add('active')
  }

  // Sposta/elimina virgola dal dividendo o divisore
  shiftComma(event) {
    const comma = event.currentTarget
    // Toggle classe "shifted" per indicare che la virgola è stata spostata
    comma.classList.toggle('shifted')
  }

  // Navigazione keyboard per commaSpot
  handleCommaSpotKeydown(event, spot) {
    switch (event.key) {
      case ' ':
      case 'Enter':
        event.preventDefault()
        this.toggleComma({ currentTarget: spot })
        break
      case 'ArrowLeft':
      case 'ArrowRight':
        // Naviga agli spot adiacenti
        event.preventDefault()
        const spots = this.commaSpotTargets
        const idx = spots.indexOf(spot)
        const nextIdx = event.key === 'ArrowRight' ? idx + 1 : idx - 1
        if (nextIdx >= 0 && nextIdx < spots.length) {
          spots[nextIdx].focus()
        }
        break
    }
  }

  // === Toolbar Actions ===

  clearGrid() {
    const inputs = this.element.querySelectorAll('input')
    inputs.forEach(input => {
      // Non cancellare gli input readonly (come il segno −)
      if (!input.hasAttribute('readonly')) {
        input.value = ''
      }
      input.classList.remove('bg-green-100', 'bg-red-100', 'bg-yellow-100',
                            'dark:bg-green-900/50', 'dark:bg-red-900/50', 'dark:bg-yellow-900/50')
      input.classList.add('bg-transparent')
    })

    // Reset comma spots nel quoziente
    if (this.hasCommaSpotTarget) {
      this.commaSpotTargets.forEach(spot => {
        spot.classList.remove('active', 'correct', 'incorrect', 'missing')
      })
    }

    // Reset comma shift nel dividendo/divisore
    if (this.hasCommaShiftTarget) {
      this.commaShiftTargets.forEach(comma => {
        comma.classList.remove('shifted')
      })
    }
  }

  showNumbers() {
    // Mostra dividendo
    if (this.hasDividendTarget) {
      this.dividendTargets.forEach(input => {
        const correctAnswer = input.getAttribute('data-correct-answer')
        if (correctAnswer) {
          input.value = correctAnswer
        }
      })
    }

    // Mostra divisore
    if (this.hasDivisorTarget) {
      this.divisorTargets.forEach(input => {
        const correctAnswer = input.getAttribute('data-correct-answer')
        if (correctAnswer) {
          input.value = correctAnswer
        }
      })
    }
  }

  showSteps() {
    // Mostra i prodotti parziali
    if (this.hasProductTarget) {
      this.productTargets.forEach(input => {
        const correctAnswer = input.getAttribute('data-correct-answer')
        if (correctAnswer) {
          input.value = correctAnswer
        }
      })
    }

    // Mostra i resti parziali
    if (this.hasRemainderTarget) {
      this.remainderTargets.forEach(input => {
        const correctAnswer = input.getAttribute('data-correct-answer')
        if (correctAnswer) {
          input.value = correctAnswer
        }
      })
    }

    // Mostra le cifre abbassate
    if (this.hasBringdownTarget) {
      this.bringdownTargets.forEach(input => {
        const correctAnswer = input.getAttribute('data-correct-answer')
        if (correctAnswer) {
          input.value = correctAnswer
        }
      })
    }
  }

  showResult() {
    // Prima mostra i passi
    this.showSteps()

    // Poi mostra il quoziente
    if (this.hasQuotientTarget) {
      this.quotientTargets.forEach(input => {
        const correctAnswer = input.getAttribute('data-correct-answer')
        if (correctAnswer) {
          input.value = correctAnswer
        }
      })
    }

    // Mostra la virgola nel quoziente se presente
    if (this.hasCommaSpotTarget) {
      // Trova lo spot con la posizione corretta e attivalo
      this.commaSpotTargets.forEach(spot => {
        spot.classList.remove('active')
        if (spot.dataset.correctPosition === 'true') {
          spot.classList.add('active')
        }
      })
    }

    // Mostra le virgole spostate nel dividendo/divisore
    if (this.hasCommaShiftTarget) {
      this.commaShiftTargets.forEach(comma => {
        // Se la divisione ha decimali nel divisore, la virgola deve essere "spostata"
        // (questo viene gestito dal backend che marca quali virgole devono essere shifted)
        if (comma.dataset.shouldShift === 'true') {
          comma.classList.add('shifted')
        }
      })
    }
  }

  verifyAnswers() {
    const allInputs = this.element.querySelectorAll('input[data-correct-answer]')

    let correct = 0
    let total = 0
    let hasErrors = false

    allInputs.forEach(input => {
      const correctAnswer = input.getAttribute('data-correct-answer')
      const userAnswer = input.value.trim()

      // Salta celle senza risposta corretta definita
      if (correctAnswer === null || correctAnswer === undefined) {
        return
      }

      // Salta celle readonly (come il segno −) - sono sempre corrette se hanno il valore
      if (input.hasAttribute('readonly')) {
        return
      }

      // Rimuovi colori precedenti
      input.classList.remove('bg-transparent', 'bg-green-100', 'bg-red-100', 'bg-yellow-100',
                            'dark:bg-green-900/50', 'dark:bg-red-900/50', 'dark:bg-yellow-900/50')

      // Caso: cella deve essere vuota
      if (correctAnswer === '') {
        if (userAnswer === '') {
          input.classList.add('bg-transparent')
          return // OK, lascia trasparente
        } else {
          input.classList.add('bg-red-100', 'dark:bg-red-900/50')
          hasErrors = true
          return
        }
      }

      // Caso: cella ha un valore
      total++

      if (userAnswer === correctAnswer) {
        input.classList.add('bg-green-100', 'dark:bg-green-900/50')
        correct++
      } else if (userAnswer !== '') {
        input.classList.add('bg-red-100', 'dark:bg-red-900/50')
        hasErrors = true
      } else {
        // Vuoto ma dovrebbe avere un valore
        input.classList.add('bg-yellow-100', 'dark:bg-yellow-900/50')
      }
    })

    // Verifica posizione virgola nel quoziente
    let commaCorrect = this.verifyCommaPosition()
    if (!commaCorrect) {
      hasErrors = true
    }

    // Confetti se tutto corretto
    if (correct === total && total > 0 && !hasErrors && commaCorrect) {
      this.jsConfetti.addConfetti({
        emojis: ['🎉', '✨', '🌟', '⭐', '💫', '➗'],
        emojiSize: 30,
        confettiNumber: 60
      })
    }
  }

  // Verifica la posizione della virgola nel quoziente
  verifyCommaPosition() {
    if (!this.hasCommaSpotTarget) {
      return true // Nessuna virgola da verificare
    }

    // Trova se c'è una posizione corretta per la virgola
    const correctSpot = this.commaSpotTargets.find(spot => spot.dataset.correctPosition === 'true')

    if (!correctSpot) {
      // Nessuna virgola richiesta nel quoziente
      // Verifica che nessuno spot sia attivo
      const activeSpot = this.commaSpotTargets.find(spot => spot.classList.contains('active'))
      if (activeSpot) {
        activeSpot.classList.add('incorrect')
        return false
      }
      return true
    }

    // C'è una posizione corretta - verifica che sia quella attiva
    const activeSpot = this.commaSpotTargets.find(spot => spot.classList.contains('active'))

    // Pulisci stati precedenti
    this.commaSpotTargets.forEach(spot => {
      spot.classList.remove('correct', 'incorrect', 'missing')
    })

    if (!activeSpot) {
      // L'utente non ha messo la virgola ma doveva
      correctSpot.classList.add('missing')
      return false
    }

    if (activeSpot === correctSpot) {
      // Posizione corretta
      activeSpot.classList.add('correct')
      return true
    } else {
      // Posizione sbagliata
      activeSpot.classList.add('incorrect')
      correctSpot.classList.add('missing')
      return false
    }
  }
}
