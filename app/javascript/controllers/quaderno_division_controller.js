import { Controller } from "@hotwired/stimulus"
import JSConfetti from "js-confetti"

/**
 * Controller per il quaderno di divisioni in colonna
 * Gestisce la navigazione tra celle, verifica delle risposte e feedback visivo
 */
export default class extends Controller {
  static targets = ["dividend", "divisor", "quotient", "product", "remainder", "bringdown", "cell"]

  connect() {
    this.jsConfetti = new JSConfetti()

    // Aggiungi event listener per la navigazione
    this.addNavigationListeners()
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
    })
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
      input.classList.remove('bg-green-100', 'bg-red-100', 'bg-yellow-100',
                            'dark:bg-green-900/50', 'dark:bg-red-900/50', 'dark:bg-yellow-900/50')

      // Caso: cella deve essere vuota
      if (correctAnswer === '') {
        if (userAnswer === '') {
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

    // Confetti se tutto corretto
    if (correct === total && total > 0 && !hasErrors) {
      this.jsConfetti.addConfetti({
        emojis: ['🎉', '✨', '🌟', '⭐', '💫', '➗'],
        emojiSize: 30,
        confettiNumber: 60
      })
    }
  }
}
