import { Controller } from "@hotwired/stimulus"
import JSConfetti from "js-confetti"

// Controller per le moltiplicazioni in colonna
export default class extends Controller {
  static targets = ["multiplicandInput", "multiplierInput", "partialInput", "carryPartial", "resultInput", "carryResult"]

  connect() {
    this.jsConfetti = new JSConfetti()
    this.setupNavigation()
  }

  setupNavigation() {
    // Raccogli tutti gli input navigabili
    const allInputs = this.getAllInputs()

    allInputs.forEach(input => {
      input.addEventListener('input', (e) => this.handleInput(e))
      input.addEventListener('keydown', (e) => this.handleKeydown(e))
    })
  }

  getAllInputs() {
    return [
      ...(this.hasCarryPartialTarget ? this.carryPartialTargets : []),
      ...(this.hasPartialInputTarget ? this.partialInputTargets : []),
      ...(this.hasCarryResultTarget ? this.carryResultTargets : []),
      ...(this.hasResultInputTarget ? this.resultInputTargets : [])
    ]
  }

  // Raggruppa gli input per riga (data-row)
  getInputsByRow() {
    const allInputs = this.getAllInputs()
    const rowMap = new Map()

    allInputs.forEach(input => {
      const row = parseInt(input.getAttribute('data-row'))
      if (!isNaN(row)) {
        if (!rowMap.has(row)) {
          rowMap.set(row, [])
        }
        rowMap.get(row).push(input)
      }
    })

    // Ordina ogni riga per colonna (da sinistra a destra = colonna decrescente)
    rowMap.forEach((inputs, row) => {
      inputs.sort((a, b) => {
        const colA = parseInt(a.getAttribute('data-column')) || 0
        const colB = parseInt(b.getAttribute('data-column')) || 0
        return colB - colA // colonna maggiore = più a sinistra
      })
    })

    return rowMap
  }

  // Ottieni le righe ordinate (dalla più alta alla più bassa)
  getSortedRows() {
    const rowMap = this.getInputsByRow()
    return Array.from(rowMap.keys()).sort((a, b) => a - b)
  }

  handleInput(event) {
    const input = event.target
    const value = input.value

    // Permetti solo numeri 0-9
    if (!/^[0-9]?$/.test(value)) {
      input.value = value.slice(0, -1)
      return
    }

    if (value !== '') {
      // Comportamento diverso per carry e input normali
      if (this.isCarryInput(input)) {
        // Carry: vai all'input sotto (stessa colonna)
        this.navigateVertical(input, 1)
      } else {
        // Input normale: vai a sinistra, se sei all'inizio vai alla riga sotto
        this.navigateInputFlow(input)
      }
    }
  }

  // Verifica se l'input è un carry
  isCarryInput(input) {
    return this.hasCarryPartialTarget && this.carryPartialTargets.includes(input) ||
           this.hasCarryResultTarget && this.carryResultTargets.includes(input)
  }

  // Navigazione per input normali: sinistra nella riga, poi inizio riga sotto (no carry)
  navigateInputFlow(currentInput) {
    const rowMap = this.getInputsByRow()
    const sortedRows = this.getSortedRows()
    const currentRow = parseInt(currentInput.getAttribute('data-row'))

    if (isNaN(currentRow)) return

    const rowInputs = rowMap.get(currentRow)
    if (!rowInputs) return

    const currentIndex = rowInputs.indexOf(currentInput)
    if (currentIndex === -1) return

    // Prova ad andare a sinistra nella stessa riga
    if (currentIndex > 0) {
      rowInputs[currentIndex - 1].focus()
      return
    }

    // Siamo all'inizio della riga: vai all'inizio della prossima riga di input (no carry)
    const currentRowIndex = sortedRows.indexOf(currentRow)

    // Cerca la prossima riga con input normali (righe dispari = input, righe pari = carry)
    for (let i = currentRowIndex + 1; i < sortedRows.length; i++) {
      const nextRow = sortedRows[i]
      // Le righe dispari sono gli input, le righe pari sono i carry
      if (nextRow % 2 === 1 || this.isResultRow(nextRow, sortedRows)) {
        const nextRowInputs = rowMap.get(nextRow)
        if (nextRowInputs && nextRowInputs.length > 0) {
          // Vai al primo input (più a sinistra) della riga
          nextRowInputs[0].focus()
          return
        }
      }
    }
  }

  // Verifica se è la riga del risultato finale
  isResultRow(row, sortedRows) {
    return row === sortedRows[sortedRows.length - 1]
  }

  handleKeydown(event) {
    const input = event.target

    switch (event.key) {
      case 'ArrowLeft':
        event.preventDefault()
        this.navigateHorizontal(input, -1)
        break
      case 'ArrowRight':
        event.preventDefault()
        this.navigateHorizontal(input, 1)
        break
      case 'ArrowUp':
        event.preventDefault()
        this.navigateVertical(input, -1)
        break
      case 'ArrowDown':
        event.preventDefault()
        this.navigateVertical(input, 1)
        break
      case 'Backspace':
        if (input.value === '') {
          event.preventDefault()
          this.navigateHorizontal(input, 1)
        }
        break
    }
  }

  // Navigazione orizzontale con wrap alla riga sopra/sotto
  navigateHorizontal(currentInput, direction) {
    const rowMap = this.getInputsByRow()
    const sortedRows = this.getSortedRows()
    const currentRow = parseInt(currentInput.getAttribute('data-row'))

    if (isNaN(currentRow)) return

    const rowInputs = rowMap.get(currentRow)
    if (!rowInputs) return

    const currentIndex = rowInputs.indexOf(currentInput)
    if (currentIndex === -1) return

    const newIndex = currentIndex + direction

    // Se siamo dentro la riga, spostiamo normalmente
    if (newIndex >= 0 && newIndex < rowInputs.length) {
      rowInputs[newIndex].focus()
      return
    }

    // Wrap alla riga sopra/sotto
    const currentRowIndex = sortedRows.indexOf(currentRow)

    if (direction < 0 && newIndex < 0) {
      // Freccia sinistra dall'inizio: vai alla fine della riga sopra
      const prevRowIndex = currentRowIndex - 1
      if (prevRowIndex >= 0) {
        const prevRow = sortedRows[prevRowIndex]
        const prevRowInputs = rowMap.get(prevRow)
        if (prevRowInputs && prevRowInputs.length > 0) {
          prevRowInputs[prevRowInputs.length - 1].focus()
        }
      }
    } else if (direction > 0 && newIndex >= rowInputs.length) {
      // Freccia destra dalla fine: vai all'inizio della riga sotto
      const nextRowIndex = currentRowIndex + 1
      if (nextRowIndex < sortedRows.length) {
        const nextRow = sortedRows[nextRowIndex]
        const nextRowInputs = rowMap.get(nextRow)
        if (nextRowInputs && nextRowInputs.length > 0) {
          nextRowInputs[0].focus()
        }
      }
    }
  }

  // Navigazione verticale nella stessa colonna
  navigateVertical(currentInput, direction) {
    const currentCol = parseInt(currentInput.getAttribute('data-column'))
    const currentRow = parseInt(currentInput.getAttribute('data-row'))

    if (isNaN(currentCol) || isNaN(currentRow)) return

    const allInputs = this.getAllInputs()

    // Trova l'input nella stessa colonna con la row più vicina nella direzione desiderata
    let bestMatch = null
    let bestRowDiff = Infinity

    allInputs.forEach(input => {
      const col = parseInt(input.getAttribute('data-column'))
      const row = parseInt(input.getAttribute('data-row'))

      if (isNaN(col) || isNaN(row)) return
      if (col !== currentCol) return
      if (input === currentInput) return

      if (direction > 0 && row > currentRow) {
        const diff = row - currentRow
        if (diff < bestRowDiff) {
          bestRowDiff = diff
          bestMatch = input
        }
      } else if (direction < 0 && row < currentRow) {
        const diff = currentRow - row
        if (diff < bestRowDiff) {
          bestRowDiff = diff
          bestMatch = input
        }
      }
    })

    if (bestMatch) {
      bestMatch.focus()
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
    const allInputs = this.getAllInputs()

    let correct = 0
    let total = 0

    allInputs.forEach(input => {
      const correctAnswer = input.getAttribute('data-correct-answer')
      const userAnswer = input.value.trim()

      // Salta le celle vuote che devono rimanere vuote
      if ((correctAnswer === '' || correctAnswer === null) && userAnswer === '') {
        return
      }

      total++

      // Rimuovi colori precedenti
      input.classList.remove('bg-green-100', 'bg-red-100')

      if (userAnswer === correctAnswer) {
        input.classList.add('bg-green-100')
        correct++
      } else if (userAnswer !== '') {
        input.classList.add('bg-red-100')
      }
    })

    // Lancia confetti se tutte le risposte sono corrette
    if (correct === total && total > 0) {
      this.jsConfetti.addConfetti({
        emojis: ['🎉', '✨', '🌟', '⭐', '💫'],
        emojiSize: 30,
        confettiNumber: 60
      })
    }
  }

  showPartials() {
    // Mostra i riporti dei prodotti parziali
    if (this.hasCarryPartialTarget) {
      this.carryPartialTargets.forEach(input => {
        const correctAnswer = input.getAttribute('data-correct-answer')
        if (correctAnswer && correctAnswer !== '') {
          input.value = correctAnswer
          input.classList.add('bg-green-100')
        }
      })
    }

    // Mostra i prodotti parziali
    if (this.hasPartialInputTarget) {
      this.partialInputTargets.forEach(input => {
        const correctAnswer = input.getAttribute('data-correct-answer')
        if (correctAnswer && correctAnswer !== '') {
          input.value = correctAnswer
          input.classList.remove('bg-red-100')
          input.classList.add('bg-green-100')
        }
      })
    }
  }

  showSolution() {
    // Prima mostra i prodotti parziali
    this.showPartials()

    // Mostra i riporti del risultato
    if (this.hasCarryResultTarget) {
      this.carryResultTargets.forEach(input => {
        const correctAnswer = input.getAttribute('data-correct-answer')
        if (correctAnswer && correctAnswer !== '') {
          input.value = correctAnswer
          input.classList.add('bg-green-100')
        }
      })
    }

    // Mostra il risultato finale
    if (this.hasResultInputTarget) {
      this.resultInputTargets.forEach(input => {
        const correctAnswer = input.getAttribute('data-correct-answer')
        if (correctAnswer && correctAnswer !== '') {
          input.value = correctAnswer
          input.classList.remove('bg-red-100')
          input.classList.add('bg-green-100')
        }
      })
    }
  }
}
