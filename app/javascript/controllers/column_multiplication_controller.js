import { Controller } from "@hotwired/stimulus"
import JSConfetti from "js-confetti"

// Controller per le moltiplicazioni in colonna
export default class extends Controller {
  static targets = ["multiplicandInput", "multiplierInput", "partialInput", "carryPartial", "resultInput", "carryResult"]

  connect() {
    this.jsConfetti = new JSConfetti()

    // Event listeners per i prodotti parziali
    if (this.hasPartialInputTarget) {
      this.partialInputTargets.forEach((input, index) => {
        input.addEventListener('input', (e) => this.handlePartialInput(e, index))
        input.addEventListener('keydown', (e) => this.handlePartialKeydown(e, index))
      })
    }

    // Event listeners per i riporti dei prodotti parziali
    if (this.hasCarryPartialTarget) {
      this.carryPartialTargets.forEach((input, index) => {
        input.addEventListener('input', (e) => this.handleCarryPartialInput(e, index))
      })
    }

    // Event listeners per il risultato finale
    if (this.hasResultInputTarget) {
      this.resultInputTargets.forEach((input, index) => {
        input.addEventListener('input', (e) => this.handleResultInput(e, index))
        input.addEventListener('keydown', (e) => this.handleResultKeydown(e, index))
      })
    }

    // Event listeners per i riporti del risultato
    if (this.hasCarryResultTarget) {
      this.carryResultTargets.forEach((input, index) => {
        input.addEventListener('input', (e) => this.handleCarryResultInput(e, index))
      })
    }
  }

  handlePartialInput(event, index) {
    const input = event.target
    const value = input.value

    // Permetti solo numeri 0-9
    if (!/^[0-9]?$/.test(value)) {
      input.value = value.slice(0, -1)
      return
    }

    // Auto-advance: passa al prossimo input se questo è compilato
    if (value !== '' && index < this.partialInputTargets.length - 1) {
      this.partialInputTargets[index + 1].focus()
    }
  }

  handlePartialKeydown(event, index) {
    const input = event.target

    // Backspace su campo vuoto: torna indietro
    if (event.key === 'Backspace' && input.value === '' && index > 0) {
      event.preventDefault()
      this.partialInputTargets[index - 1].focus()
    }

    // ArrowLeft: vai al precedente
    if (event.key === 'ArrowLeft' && index > 0) {
      event.preventDefault()
      this.partialInputTargets[index - 1].focus()
    }

    // ArrowRight: vai al successivo
    if (event.key === 'ArrowRight' && index < this.partialInputTargets.length - 1) {
      event.preventDefault()
      this.partialInputTargets[index + 1].focus()
    }
  }

  handleCarryPartialInput(event, index) {
    const input = event.target
    const value = input.value

    // Permetti solo numeri 0-9
    if (!/^[0-9]?$/.test(value)) {
      input.value = value.slice(0, -1)
      return
    }

    // Auto-advance verso destra per i riporti
    if (value !== '' && index < this.carryPartialTargets.length - 1) {
      this.carryPartialTargets[index + 1].focus()
    }
  }

  handleResultInput(event, index) {
    const input = event.target
    const value = input.value

    // Permetti solo numeri 0-9
    if (!/^[0-9]?$/.test(value)) {
      input.value = value.slice(0, -1)
      return
    }

    // Auto-advance
    if (value !== '' && index < this.resultInputTargets.length - 1) {
      this.resultInputTargets[index + 1].focus()
    }
  }

  handleResultKeydown(event, index) {
    const input = event.target

    // Backspace su campo vuoto: torna indietro
    if (event.key === 'Backspace' && input.value === '' && index > 0) {
      event.preventDefault()
      this.resultInputTargets[index - 1].focus()
    }

    // ArrowLeft
    if (event.key === 'ArrowLeft' && index > 0) {
      event.preventDefault()
      this.resultInputTargets[index - 1].focus()
    }

    // ArrowRight
    if (event.key === 'ArrowRight' && index < this.resultInputTargets.length - 1) {
      event.preventDefault()
      this.resultInputTargets[index + 1].focus()
    }
  }

  handleCarryResultInput(event, index) {
    const input = event.target
    const value = input.value

    // Permetti solo numeri 0-9
    if (!/^[0-9]?$/.test(value)) {
      input.value = value.slice(0, -1)
      return
    }

    // Auto-advance
    if (value !== '' && index < this.carryResultTargets.length - 1) {
      this.carryResultTargets[index + 1].focus()
    }
  }

  // Toolbar Actions
  clearGrid() {
    const inputs = this.element.querySelectorAll('input')
    inputs.forEach(input => {
      input.value = ''
      input.classList.remove('bg-green-100', 'bg-red-100')
    })
  }

  checkResults() {
    // Ottieni moltiplicando e moltiplicatore
    const multiplicand = parseInt(this.element.dataset.multiplicand)
    const multiplier = parseInt(this.element.dataset.multiplier)

    if (isNaN(multiplicand) || isNaN(multiplier)) return

    const product = multiplicand * multiplier

    // Verifica il risultato finale
    const resultDigits = product.toString().split('').reverse()
    let correct = 0
    let total = 0

    this.resultInputTargets.forEach((input, index) => {
      if (input.value !== '') {
        total++
        const expectedDigit = resultDigits[index] || '0'
        if (input.value === expectedDigit) {
          correct++
          input.classList.remove('bg-red-100')
          input.classList.add('bg-green-100')
        } else {
          input.classList.remove('bg-green-100')
          input.classList.add('bg-red-100')
        }
      }
    })

    // Lancia confetti se tutte le risposte sono corrette
    if (correct === total && total > 0 && correct === resultDigits.length) {
      this.jsConfetti.addConfetti({
        emojis: ['🎉', '✨', '🌟', '⭐', '💫'],
        emojiSize: 30,
        confettiNumber: 60
      })
    }
  }

  showSolution() {
    const multiplicand = parseInt(this.element.dataset.multiplicand)
    const multiplier = parseInt(this.element.dataset.multiplier)

    if (isNaN(multiplicand) || isNaN(multiplier)) return

    const product = multiplicand * multiplier
    const resultDigits = product.toString().split('').reverse()

    // Mostra il risultato
    this.resultInputTargets.forEach((input, index) => {
      input.value = resultDigits[index] || ''
      input.classList.remove('bg-red-100')
      input.classList.add('bg-green-100')
    })
  }
}
