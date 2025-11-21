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

    // Verifica il risultato finale (i target sono da sinistra a destra, le cifre da destra a sinistra)
    const resultDigits = product.toString().split('')
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

    // Mostra i prodotti parziali (se presenti)
    if (this.hasPartialInputTarget) {
      const multiplicandDigits = multiplicand.toString().split('').reverse()
      const multiplierDigits = multiplier.toString().split('').reverse()  // Reverse: inizia dalle unità
      let partialInputIndex = 0
      let carryPartialIndex = 0

      // Calcola product_length per determinare il numero di input per riga
      const productLength = (multiplicand * multiplier).toString().length

      multiplierDigits.forEach((digit, rowIndex) => {
        const partialProduct = multiplicand * parseInt(digit)
        const partialDigits = partialProduct.toString().split('')  // Da sinistra a destra

        // Numero di input per questa riga = product_length - zeri_segnaposto (row_index)
        const numInputsForRow = productLength - rowIndex
        const numCarriesForRow = numInputsForRow - 1

        // Calcola i riporti
        const multiplicandDigitsReversed = multiplicand.toString().split('').reverse()
        let carry = 0
        const carries = []

        for (let i = 0; i < multiplicandDigitsReversed.length; i++) {
          const multiplicandDigit = parseInt(multiplicandDigitsReversed[i])
          const product = multiplicandDigit * parseInt(digit) + carry
          carry = Math.floor(product / 10)
          carries.push(carry)
        }

        // Riempi le cifre del prodotto parziale (allineate a destra negli input)
        // Gli input vanno da sinistra a destra, le cifre del prodotto parziale anche
        // Ma dobbiamo allineare a destra: se il prodotto ha meno cifre degli input,
        // le prime caselle restano vuote
        const offset = numInputsForRow - partialDigits.length
        partialDigits.forEach((d, i) => {
          const targetIdx = partialInputIndex + offset + i
          if (this.partialInputTargets[targetIdx]) {
            this.partialInputTargets[targetIdx].value = d
            this.partialInputTargets[targetIdx].classList.remove('bg-red-100')
            this.partialInputTargets[targetIdx].classList.add('bg-green-100')
          }
        })

        // Riempi i riporti (allineati a sinistra, sopra le cifre di ordine superiore)
        // carries[0] è il riporto dalla prima moltiplicazione (unità), va nella posizione più a destra dei riporti
        // carries[1] è il riporto dalla seconda moltiplicazione (decine), va una posizione a sinistra
        carries.forEach((c, i) => {
          if (c > 0) {
            // L'indice nel target: i riporti sono da sinistra a destra
            // carries[0] (dalle unità) va nella posizione più a destra (numCarriesForRow - 1)
            const targetIdx = carryPartialIndex + (numCarriesForRow - 1 - i)
            if (this.carryPartialTargets[targetIdx]) {
              this.carryPartialTargets[targetIdx].value = c.toString()
              this.carryPartialTargets[targetIdx].classList.add('bg-green-100')
            }
          }
        })

        partialInputIndex += numInputsForRow
        carryPartialIndex += numCarriesForRow
      })
    }

    // Mostra il risultato finale con riporti
    const product = multiplicand * multiplier
    const resultDigits = product.toString().split('')
    const productLength = product.toString().length

    // Calcola i riporti per la somma finale (se ci sono prodotti parziali)
    if (this.hasPartialInputTarget && this.hasCarryResultTarget) {
      const multiplierDigits = multiplier.toString().split('').reverse()  // Reverse: inizia dalle unità
      const productDigitsReversed = product.toString().split('').reverse()

      let carry = 0
      for (let col = 0; col < productLength; col++) {
        let sum = carry

        // Somma le cifre dei prodotti parziali per questa colonna (da destra a sinistra)
        multiplierDigits.forEach((digit, rowIndex) => {
          const partialProduct = multiplicand * parseInt(digit)
          const partialString = partialProduct.toString()
          const colInPartial = col - rowIndex

          if (colInPartial >= 0 && colInPartial < partialString.length) {
            const partialDigits = partialString.split('').reverse()
            sum += parseInt(partialDigits[colInPartial])
          }
        })

        carry = Math.floor(sum / 10)

        // Mostra il riporto se > 0 (l'indice nei target va da sinistra a destra)
        if (carry > 0 && col < productLength - 1) {
          const targetIndex = productLength - col - 1
          if (this.carryResultTargets[targetIndex]) {
            this.carryResultTargets[targetIndex].value = carry.toString()
            this.carryResultTargets[targetIndex].classList.add('bg-green-100')
          }
        }
      }
    } else if (this.hasCarryResultTarget) {
      // Moltiplicazione semplice (senza prodotti parziali): calcola i riporti della moltiplicazione diretta
      const multiplicandDigitsReversed = multiplicand.toString().split('').reverse()
      let carry = 0

      for (let i = 0; i < multiplicandDigitsReversed.length; i++) {
        const digit = parseInt(multiplicandDigitsReversed[i])
        const partialResult = digit * multiplier + carry
        carry = Math.floor(partialResult / 10)

        // Mostra il riporto se > 0
        // I carryResultTargets hanno productLength + 1 elementi (indici 0 a productLength)
        // I resultInputTargets hanno productLength elementi (indici 0 a productLength - 1)
        // carryResult[k] è sopra result[k-1] (shiftato di 1 a sinistra)
        // Il riporto dalla moltiplicazione della cifra i (da destra) va sopra la cifra i+1 (da destra) del risultato
        // Cifra i+1 da destra nel risultato = indice (productLength - 1) - (i + 1) = productLength - i - 2
        // Casella riporto corrispondente = (productLength - i - 2) + 1 = productLength - i - 1
        if (carry > 0 && i < multiplicandDigitsReversed.length - 1) {
          const targetIndex = productLength - i - 1
          if (targetIndex >= 0 && this.carryResultTargets[targetIndex]) {
            this.carryResultTargets[targetIndex].value = carry.toString()
            this.carryResultTargets[targetIndex].classList.add('bg-green-100')
          }
        }
      }
    }

    // Mostra il risultato finale
    this.resultInputTargets.forEach((input, index) => {
      input.value = resultDigits[index] || ''
      input.classList.remove('bg-red-100')
      input.classList.add('bg-green-100')
    })
  }
}
