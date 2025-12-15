import { Controller } from "@hotwired/stimulus"
import JSConfetti from "js-confetti"

/**
 * Controller per il quaderno di addizioni
 * Gestisce la navigazione tra celle, verifica delle risposte e feedback visivo
 */
export default class extends Controller {
  static targets = ["input", "result", "carry", "comma"]

  connect() {
    this.jsConfetti = new JSConfetti()

    // Costruisci array ordinato di tutte le celle editabili per riga
    this.buildCellGrid()

    // Aggiungi event listener a tutte le celle
    this.allAddendCells.forEach((cell, index) => {
      cell.addEventListener('input', (e) => this.handleCellInput(e, index, 'addend'))
      cell.addEventListener('keydown', (e) => this.handleCellKeydown(e, index, 'addend'))
    })

    this.allResultCells.forEach((cell, index) => {
      cell.addEventListener('input', (e) => this.handleCellInput(e, index, 'result'))
      cell.addEventListener('keydown', (e) => this.handleCellKeydown(e, index, 'result'))
    })

    if (this.hasCarryTarget) {
      this.carryTargets.forEach((cell, index) => {
        cell.addEventListener('input', (e) => this.handleCarryInput(e, index))
        cell.addEventListener('keydown', (e) => this.handleCarryKeydown(e, index))
      })
    }
  }

  buildCellGrid() {
    const grid = this.element.querySelector('.inline-grid')

    if (!grid) {
      this.allAddendCells = [...this.inputTargets]
      this.allResultCells = [...this.resultTargets]
      this.cellsPerRow = this.inputTargets.length / 2
      this.columnMap = {}
      this.allCellsOrdered = []
      return
    }

    // Raccogli tutte le celle input in ordine DOM
    const allCells = grid.querySelectorAll(
      '[data-quaderno-addition-target="input"], [data-quaderno-addition-target="result"], [data-quaderno-addition-target="comma"], [data-quaderno-addition-target="carry"]'
    )

    this.allAddendCells = []
    this.allResultCells = []

    // Mappa colonne: per ogni colonna, lista di celle dall'alto al basso
    this.columnMap = {}

    // Calcola il numero di colonne dalla griglia CSS
    const gridStyle = window.getComputedStyle(grid)
    const cols = gridStyle.gridTemplateColumns.split(' ').length

    // Array con tutte le celle e le loro posizioni per ordinamento
    const cellsWithPositions = []

    // Organizza celle per posizione nella griglia
    allCells.forEach(cell => {
      const targetType = cell.getAttribute('data-quaderno-addition-target')

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

      // Salva per ordinamento globale
      cellsWithPositions.push({ cell, gridIndex })

      // Separa anche in addend/result cells per compatibilità
      if (targetType === 'result') {
        this.allResultCells.push(cell)
      } else if (targetType === 'input') {
        this.allAddendCells.push(cell)
      } else if (targetType === 'comma') {
        const rowType = cell.getAttribute('data-row-type')
        if (rowType === 'result') {
          this.allResultCells.push(cell)
        } else {
          this.allAddendCells.push(cell)
        }
      }
      // carry cells sono già gestiti separatamente
    })

    // Crea lista ordinata di tutte le celle (riga per riga, da sinistra a destra)
    cellsWithPositions.sort((a, b) => a.gridIndex - b.gridIndex)
    this.allCellsOrdered = cellsWithPositions.map(item => item.cell)

    // Calcola celle per riga
    const numAddends = 2
    this.cellsPerRow = Math.floor(this.allAddendCells.length / numAddends)
  }

  // === Gestione Input Celle ===

  handleCellInput(event, currentIndex, type) {
    const input = event.target
    const value = input.value

    if (value.length === 1) {
      const cells = type === 'addend' ? this.allAddendCells : this.allResultCells

      if (type === 'result') {
        // Nel risultato, naviga da destra a sinistra
        if (currentIndex > 0) {
          cells[currentIndex - 1].focus()
          cells[currentIndex - 1].select()
        }
      } else {
        // Negli addendi, naviga da sinistra a destra
        if (currentIndex < cells.length - 1) {
          cells[currentIndex + 1].focus()
          cells[currentIndex + 1].select()
        } else if (this.allResultCells.length > 0) {
          // Fine addendi, vai al risultato (ultima cella - unità)
          const lastResult = this.allResultCells[this.allResultCells.length - 1]
          lastResult.focus()
          lastResult.select()
        }
      }
    }
  }

  handleCellKeydown(event, currentIndex, type) {
    const input = event.target
    const cells = type === 'addend' ? this.allAddendCells : this.allResultCells

    switch (event.key) {
      case 'Backspace':
        if (input.value === '') {
          event.preventDefault()
          if (type === 'result') {
            // Nel risultato, backspace va a destra
            if (currentIndex < cells.length - 1) {
              cells[currentIndex + 1].focus()
              cells[currentIndex + 1].select()
            }
          } else {
            // Negli addendi, backspace va a sinistra
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
        } else {
          // Prima cella della riga, vai alla riga precedente
          this.navigateGlobal(input, -1)
        }
        break

      case 'ArrowRight':
        event.preventDefault()
        if (currentIndex < cells.length - 1) {
          cells[currentIndex + 1].focus()
          cells[currentIndex + 1].select()
        } else {
          // Ultima cella della riga, vai alla riga successiva
          this.navigateGlobal(input, 1)
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

  // Navigazione globale tra tutte le celle (cross-row)
  // Usata quando si raggiunge il bordo di una riga
  navigateGlobal(currentCell, direction) {
    const currentIdx = this.allCellsOrdered.indexOf(currentCell)
    if (currentIdx === -1) return

    let targetIdx = currentIdx + direction

    // Continua nella direzione finché non trovi una cella abilitata
    while (targetIdx >= 0 && targetIdx < this.allCellsOrdered.length) {
      const targetCell = this.allCellsOrdered[targetIdx]
      if (!targetCell.disabled) {
        targetCell.focus()
        targetCell.select()
        return
      }
      targetIdx += direction
    }
  }

  // Navigazione verticale usando la mappa colonne
  navigateVertical(currentCell, direction) {
    // Trova la colonna della cella corrente
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
    let targetRow = currentRowInCol + direction

    // Continua nella direzione finché non trovi una cella abilitata o esci dai limiti
    while (targetRow >= 0 && targetRow < columnCells.length) {
      const targetCell = columnCells[targetRow]
      if (!targetCell.disabled) {
        targetCell.focus()
        targetCell.select()
        return
      }
      targetRow += direction
    }
  }

  // === Gestione Carry ===

  handleCarryInput(event, currentIndex) {
    const value = event.target.value

    if (value.length === 1) {
      // Dopo aver digitato, vai alla stessa colonna nel risultato - usa il mapping
      const resultIdx = this.carryToAddendMap[currentIndex]
      if (resultIdx !== undefined && resultIdx < this.allResultCells.length) {
        this.allResultCells[resultIdx].focus()
        this.allResultCells[resultIdx].select()
      }
    }
  }

  handleCarryKeydown(event, currentIndex) {
    const input = event.target

    switch (event.key) {
      case 'Backspace':
        if (input.value === '') {
          event.preventDefault()
          this.navigateGlobal(input, -1)
        }
        break

      case 'ArrowLeft':
        event.preventDefault()
        this.navigateGlobal(input, -1)
        break

      case 'ArrowRight':
        event.preventDefault()
        this.navigateGlobal(input, 1)
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

  showAddends() {
    // Mostra tutti gli input degli addendi (incluse virgole)
    this.allAddendCells.forEach(input => {
      const correctAnswer = input.getAttribute('data-correct-answer')
      if (correctAnswer) {
        input.value = correctAnswer
      }
    })
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

    // Mostra i risultati (incluse virgole)
    this.allResultCells.forEach(input => {
      const correctAnswer = input.getAttribute('data-correct-answer')
      if (correctAnswer) {
        input.value = correctAnswer
      }
    })
  }

  verifyAnswers() {
    // Raccogli tutti gli input
    const carries = this.hasCarryTarget ? Array.from(this.carryTargets) : []
    const allInputs = [...carries, ...this.allAddendCells, ...this.allResultCells]

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
          // Corretto: la cella è vuota come dovrebbe essere - nessun colore
          input.classList.add('bg-transparent')
        } else {
          // Errore: l'utente ha inserito qualcosa in una cella che dovrebbe essere vuota
          input.classList.add('bg-red-100', 'dark:bg-red-900/50')
          hasErrors = true
        }
        return
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
