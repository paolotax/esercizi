import { Controller } from "@hotwired/stimulus"
import JSConfetti from "js-confetti"

/**
 * Controller per il quaderno di moltiplicazioni
 * Gestisce la navigazione tra celle, verifica delle risposte e feedback visivo
 */
export default class extends Controller {
  static targets = ["multiplicand", "multiplier", "result", "carry", "partial", "sumCarry", "comma"]

  connect() {
    this.jsConfetti = new JSConfetti()

    // Costruisci mappa colonne per navigazione verticale
    this.buildCellGrid()

    // Aggiungi event listener a tutte le celle
    this.multiplicandTargets.forEach((cell, index) => {
      cell.addEventListener('input', (e) => this.handleCellInput(e, index, 'multiplicand'))
      cell.addEventListener('keydown', (e) => this.handleCellKeydown(e, index, 'multiplicand'))
    })

    this.multiplierTargets.forEach((cell, index) => {
      cell.addEventListener('input', (e) => this.handleCellInput(e, index, 'multiplier'))
      cell.addEventListener('keydown', (e) => this.handleCellKeydown(e, index, 'multiplier'))
    })

    this.resultTargets.forEach((cell, index) => {
      cell.addEventListener('input', (e) => this.handleCellInput(e, index, 'result'))
      cell.addEventListener('keydown', (e) => this.handleCellKeydown(e, index, 'result'))
    })

    if (this.hasCarryTarget) {
      this.carryTargets.forEach((cell, index) => {
        cell.addEventListener('input', (e) => this.handleCarryInput(e, index))
        cell.addEventListener('keydown', (e) => this.handleCarryKeydown(e, index))
      })
    }

    if (this.hasPartialTarget) {
      this.partialTargets.forEach((cell, index) => {
        cell.addEventListener('input', (e) => this.handleCellInput(e, index, 'partial'))
        cell.addEventListener('keydown', (e) => this.handleCellKeydown(e, index, 'partial'))
      })
    }

    if (this.hasSumCarryTarget) {
      this.sumCarryTargets.forEach((cell, index) => {
        cell.addEventListener('input', (e) => this.handleCarryInput(e, index))
        cell.addEventListener('keydown', (e) => this.handleCarryKeydown(e, index))
      })
    }
  }

  buildCellGrid() {
    const grid = this.element.querySelector('.inline-grid')

    if (!grid) {
      this.columnMap = {}
      return
    }

    // Raccogli tutte le celle input in ordine DOM (inclusa la virgola)
    const allCells = grid.querySelectorAll(
      '[data-quaderno-multiplication-target="multiplicand"], [data-quaderno-multiplication-target="multiplier"], [data-quaderno-multiplication-target="result"], [data-quaderno-multiplication-target="carry"], [data-quaderno-multiplication-target="partial"], [data-quaderno-multiplication-target="sumCarry"], [data-quaderno-multiplication-target="comma"]'
    )

    // Mappa colonne: per ogni colonna, lista di celle dall'alto al basso
    this.columnMap = {}

    // Calcola il numero di colonne dalla griglia CSS
    const gridStyle = window.getComputedStyle(grid)
    const cols = gridStyle.gridTemplateColumns.split(' ').length

    // Organizza celle per posizione nella griglia
    allCells.forEach(cell => {
      // Trova la posizione nella griglia contando tutti i div figli
      const allDivs = Array.from(grid.children)
      const cellParent = cell.parentElement
      const gridIndex = allDivs.indexOf(cellParent)
      const col = gridIndex % cols

      // Inizializza colonna se non esiste
      if (!this.columnMap[col]) {
        this.columnMap[col] = []
      }

      // Aggiungi cella alla mappa colonne
      this.columnMap[col].push(cell)
    })
  }

  // === Gestione Input Celle ===

  handleCellInput(event, currentIndex, type) {
    const input = event.target
    const value = input.value

    if (value.length === 1) {
      let cells
      if (type === 'multiplicand') cells = this.multiplicandTargets
      else if (type === 'multiplier') cells = this.multiplierTargets
      else if (type === 'partial') cells = this.partialTargets
      else cells = this.resultTargets

      if (type === 'result' || type === 'partial') {
        // Nel risultato, naviga da destra a sinistra
        if (currentIndex > 0) {
          cells[currentIndex - 1].focus()
          cells[currentIndex - 1].select()
        }
      } else {
        // Nel moltiplicando/moltiplicatore, naviga da sinistra a destra
        if (currentIndex < cells.length - 1) {
          cells[currentIndex + 1].focus()
          cells[currentIndex + 1].select()
        } else if (type === 'multiplicand') {
          // Fine moltiplicando, vai al moltiplicatore
          if (this.multiplierTargets.length > 0) {
            this.multiplierTargets[0].focus()
            this.multiplierTargets[0].select()
          }
        } else if (type === 'multiplier') {
          // Fine moltiplicatore, vai al risultato (ultima cella - unità)
          if (this.resultTargets.length > 0) {
            const lastResult = this.resultTargets[this.resultTargets.length - 1]
            lastResult.focus()
            lastResult.select()
          }
        }
      }
    }
  }

  handleCellKeydown(event, currentIndex, type) {
    const input = event.target
    let cells
    if (type === 'multiplicand') cells = this.multiplicandTargets
    else if (type === 'multiplier') cells = this.multiplierTargets
    else if (type === 'partial') cells = this.partialTargets
    else cells = this.resultTargets

    switch (event.key) {
      case 'Backspace':
        if (input.value === '') {
          event.preventDefault()
          if (type === 'result' || type === 'partial') {
            // Nel risultato, backspace va a destra
            if (currentIndex < cells.length - 1) {
              cells[currentIndex + 1].focus()
              cells[currentIndex + 1].select()
            }
          } else {
            // Nel moltiplicando/moltiplicatore, backspace va a sinistra
            if (currentIndex > 0) {
              cells[currentIndex - 1].focus()
              cells[currentIndex - 1].select()
            }
          }
        }
        break

      case 'ArrowLeft':
        event.preventDefault()
        if (currentIndex > 0) {
          cells[currentIndex - 1].focus()
          cells[currentIndex - 1].select()
        }
        break

      case 'ArrowRight':
        event.preventDefault()
        if (currentIndex < cells.length - 1) {
          cells[currentIndex + 1].focus()
          cells[currentIndex + 1].select()
        }
        break

      case 'ArrowUp':
        event.preventDefault()
        this.navigateVertical(input, -1)
        break

      case 'ArrowDown':
        event.preventDefault()
        this.navigateVertical(input, 1)
        break
    }
  }

  // Navigazione verticale usando la mappa colonne
  navigateVertical(currentCell, direction) {
    let currentCol = null
    let currentRowInCol = null

    for (const [col, cells] of Object.entries(this.columnMap)) {
      const rowIndex = cells.indexOf(currentCell)
      if (rowIndex !== -1) {
        currentCol = parseInt(col)
        currentRowInCol = rowIndex
        break
      }
    }

    if (currentCol === null || currentRowInCol === null) return

    const columnCells = this.columnMap[currentCol]
    const targetRow = currentRowInCol + direction

    if (targetRow >= 0 && targetRow < columnCells.length) {
      columnCells[targetRow].focus()
      columnCells[targetRow].select()
    }
  }

  // === Gestione Carry ===

  handleCarryInput(event, currentIndex) {
    const value = event.target.value

    if (value.length === 1) {
      // Dopo aver digitato, vai al moltiplicando nella stessa colonna
      if (currentIndex < this.multiplicandTargets.length) {
        this.multiplicandTargets[currentIndex].focus()
        this.multiplicandTargets[currentIndex].select()
      }
    }
  }

  handleCarryKeydown(event, currentIndex) {
    const input = event.target

    switch (event.key) {
      case 'Backspace':
        if (input.value === '' && currentIndex > 0) {
          event.preventDefault()
          this.carryTargets[currentIndex - 1].focus()
          this.carryTargets[currentIndex - 1].select()
        }
        break

      case 'ArrowLeft':
        event.preventDefault()
        if (currentIndex > 0) {
          this.carryTargets[currentIndex - 1].focus()
          this.carryTargets[currentIndex - 1].select()
        }
        break

      case 'ArrowRight':
        event.preventDefault()
        if (currentIndex < this.carryTargets.length - 1) {
          this.carryTargets[currentIndex + 1].focus()
          this.carryTargets[currentIndex + 1].select()
        }
        break

      case 'ArrowDown':
        event.preventDefault()
        this.navigateVertical(input, 1)
        break

      case 'ArrowUp':
        event.preventDefault()
        this.navigateVertical(input, -1)
        break
    }
  }

  // === Toolbar Actions ===

  clearGrid() {
    const inputs = this.element.querySelectorAll('input')
    inputs.forEach(input => {
      input.value = ''
      input.classList.remove('bg-green-100', 'bg-red-100', 'bg-yellow-100', 'dark:bg-green-900/50', 'dark:bg-red-900/50', 'dark:bg-yellow-900/50')
      input.classList.add('bg-transparent')
    })
  }

  showNumbers() {
    // Mostra moltiplicando
    this.multiplicandTargets.forEach(input => {
      const correctAnswer = input.getAttribute('data-correct-answer')
      if (correctAnswer) {
        input.value = correctAnswer
      }
    })

    // Mostra moltiplicatore
    this.multiplierTargets.forEach(input => {
      const correctAnswer = input.getAttribute('data-correct-answer')
      if (correctAnswer) {
        input.value = correctAnswer
      }
    })

    // Mostra virgole (solo quelle di moltiplicando e moltiplicatore)
    if (this.hasCommaTarget) {
      this.commaTargets.forEach(input => {
        const rowType = input.getAttribute('data-row-type')
        if (rowType === 'multiplicand' || rowType === 'multiplier') {
          const correctAnswer = input.getAttribute('data-correct-answer')
          if (correctAnswer) {
            input.value = correctAnswer
          }
        }
      })
    }
  }

  showResult() {
    // Mostra i riporti
    if (this.hasCarryTarget) {
      this.carryTargets.forEach(input => {
        const correctAnswer = input.getAttribute('data-correct-answer')
        if (correctAnswer) {
          input.value = correctAnswer
        }
      })
    }

    // Mostra i prodotti parziali
    if (this.hasPartialTarget) {
      this.partialTargets.forEach(input => {
        const correctAnswer = input.getAttribute('data-correct-answer')
        if (correctAnswer) {
          input.value = correctAnswer
        }
      })
    }

    // Mostra i riporti della somma
    if (this.hasSumCarryTarget) {
      this.sumCarryTargets.forEach(input => {
        const correctAnswer = input.getAttribute('data-correct-answer')
        if (correctAnswer) {
          input.value = correctAnswer
        }
      })
    }

    // Mostra i risultati
    this.resultTargets.forEach(input => {
      const correctAnswer = input.getAttribute('data-correct-answer')
      if (correctAnswer) {
        input.value = correctAnswer
      }
    })

    // Mostra virgola nel risultato
    if (this.hasCommaTarget) {
      this.commaTargets.forEach(input => {
        const rowType = input.getAttribute('data-row-type')
        if (rowType === 'result') {
          const correctAnswer = input.getAttribute('data-correct-answer')
          if (correctAnswer) {
            input.value = correctAnswer
          }
        }
      })
    }
  }

  verifyAnswers() {
    // Raccogli tutti gli input
    const carries = this.hasCarryTarget ? Array.from(this.carryTargets) : []
    const partials = this.hasPartialTarget ? Array.from(this.partialTargets) : []
    const sumCarries = this.hasSumCarryTarget ? Array.from(this.sumCarryTargets) : []
    const commas = this.hasCommaTarget ? Array.from(this.commaTargets) : []
    const allInputs = [...carries, ...this.multiplicandTargets, ...this.multiplierTargets, ...commas, ...partials, ...sumCarries, ...this.resultTargets]

    let correct = 0
    let total = 0
    let hasErrors = false

    allInputs.forEach(input => {
      const correctAnswer = input.getAttribute('data-correct-answer')
      const userAnswer = input.value.trim()

      // Salta celle disabilitate o senza attributo data-correct-answer
      if (input.disabled || correctAnswer === null) {
        return
      }

      // Rimuovi colori precedenti
      input.classList.remove('bg-transparent', 'bg-green-100', 'bg-red-100', 'bg-yellow-100', 'dark:bg-green-900/50', 'dark:bg-red-900/50', 'dark:bg-yellow-900/50')

      // Caso 1: la cella deve essere vuota (correctAnswer è stringa vuota)
      if (correctAnswer === '') {
        if (userAnswer === '') {
          // Corretto: la cella è vuota come dovrebbe essere - ripristina trasparente
          input.classList.add('bg-transparent')
          return
        } else {
          // Errore: l'utente ha inserito qualcosa in una cella che dovrebbe essere vuota
          input.classList.add('bg-red-100', 'dark:bg-red-900/50')
          hasErrors = true
          return
        }
      }

      // Caso 2: la cella ha un valore corretto da inserire
      total++

      if (userAnswer === correctAnswer) {
        input.classList.add('bg-green-100', 'dark:bg-green-900/50')
        correct++
      } else if (userAnswer !== '') {
        input.classList.add('bg-red-100', 'dark:bg-red-900/50')
        hasErrors = true
      } else {
        // Cella vuota ma dovrebbe avere un valore - mostra giallo
        input.classList.add('bg-yellow-100', 'dark:bg-yellow-900/50')
      }
    })

    // Lancia confetti se tutte le risposte sono corrette e non ci sono errori
    if (correct === total && total > 0 && !hasErrors) {
      this.jsConfetti.addConfetti({
        emojis: ['🎉', '✨', '🌟', '⭐', '💫'],
        emojiSize: 30,
        confettiNumber: 60
      })
    }
  }
}
