import { Controller } from "@hotwired/stimulus"
import JSConfetti from "js-confetti"

/**
 * Controller unificato per quaderno operazioni
 * Gestisce addizione, sottrazione, moltiplicazione, divisione
 */
export default class extends Controller {
  static targets = ["input", "result", "carry", "commaSpot", "commaShift"]

  connect() {
    this.jsConfetti = new JSConfetti()
    this.buildCellGrid()
    this.addNavigationListeners()
  }

  // === Setup ===

  buildCellGrid() {
    const grid = this.element.querySelector('.inline-grid')

    if (!grid) {
      this.columnMap = {}
      this.allCellsOrdered = []
      this.allNavigableOrdered = []
      return
    }

    // Raccogli tutte le celle input in ordine DOM
    const allCells = grid.querySelectorAll('input[type="text"]')

    // Mappa colonne per navigazione verticale
    this.columnMap = {}

    // Calcola il numero di colonne dalla griglia CSS
    const gridStyle = window.getComputedStyle(grid)
    const cols = gridStyle.gridTemplateColumns.split(' ').length

    // Array con tutte le celle e le loro posizioni per ordinamento
    const cellsWithPositions = []

    allCells.forEach(cell => {
      // Trova la posizione nella griglia
      const allDivs = Array.from(grid.children)
      const cellParent = cell.closest('div[style*="height"]') || cell.parentElement
      const gridIndex = allDivs.indexOf(cellParent)
      const col = gridIndex % cols

      // Inizializza colonna se non esiste
      if (!this.columnMap[col]) {
        this.columnMap[col] = []
      }
      this.columnMap[col].push(cell)

      // Salva per ordinamento globale
      cellsWithPositions.push({ element: cell, gridIndex, type: 'input' })
    })

    // Aggiungi anche i commaSpot per la navigazione orizzontale
    if (this.hasCommaSpotTarget) {
      this.commaSpotTargets.forEach(spot => {
        const allDivs = Array.from(grid.children)
        const spotParent = spot.closest('div[style*="height"]') || spot.parentElement
        const gridIndex = allDivs.indexOf(spotParent)
        // Aggiungi un piccolo offset per posizionare lo spot dopo l'input nella stessa cella
        cellsWithPositions.push({ element: spot, gridIndex: gridIndex + 0.5, type: 'commaSpot' })
      })
    }

    // Crea lista ordinata di tutte le celle (riga per riga, da sinistra a destra)
    cellsWithPositions.sort((a, b) => a.gridIndex - b.gridIndex)
    this.allCellsOrdered = cellsWithPositions.filter(item => item.type === 'input').map(item => item.element)
    this.allNavigableOrdered = cellsWithPositions.map(item => item.element)
  }

  addNavigationListeners() {
    this.allCellsOrdered.forEach((cell, index) => {
      cell.addEventListener('input', (e) => this.handleCellInput(e, index))
      cell.addEventListener('keydown', (e) => this.handleCellKeydown(e, index))
    })

    // Listener per commaSpot
    if (this.hasCommaSpotTarget) {
      this.commaSpotTargets.forEach(spot => {
        spot.addEventListener('keydown', (e) => this.handleCommaSpotKeydown(e, spot))
      })
    }
  }

  // === Input Handling ===

  handleCellInput(event, currentIndex) {
    const input = event.target
    const value = input.value
    const target = input.dataset.quadernoTarget

    // Gestione sbiadimento minuendo per sottrazione
    if (target === 'carry') {
      this.handleCarryFade(input, value)
    }

    if (value.length === 1) {
      const navDirection = input.dataset.navDirection || 'ltr'

      if (navDirection === 'rtl') {
        // Right-to-left: vai alla cella precedente (a sinistra)
        this.navigateToNextEnabled(currentIndex, -1)
      } else {
        // Left-to-right: vai alla cella successiva (a destra)
        this.navigateToNextEnabled(currentIndex, 1)
      }
    }
  }

  // Sbiadisce/ripristina il minuendo quando si scrive un prestito (solo sottrazione)
  handleCarryFade(carryInput, value) {
    // Verifica se il carry ha classe text-red (prestito sottrazione)
    if (!carryInput.classList.contains('text-red-600') &&
        !carryInput.classList.contains('dark:text-red-400')) {
      return // Non e' un prestito di sottrazione
    }

    // Trova l'input nella stessa colonna ma nella riga sotto (minuendo)
    const col = carryInput.dataset.col
    if (!col) return

    // Cerca l'input con target "input" nella stessa colonna
    const minuendInput = this.element.querySelector(
      `input[data-quaderno-target="input"][data-col="${col}"]`
    )

    if (!minuendInput) return

    if (value !== '') {
      // Sbiadisci il minuendo
      minuendInput.classList.add('text-gray-300', 'dark:text-gray-600')
      minuendInput.classList.remove('text-gray-800', 'dark:text-gray-100')
    } else {
      // Ripristina il minuendo
      minuendInput.classList.remove('text-gray-300', 'dark:text-gray-600')
      minuendInput.classList.add('text-gray-800', 'dark:text-gray-100')
    }
  }

  handleCellKeydown(event, currentIndex) {
    const input = event.target
    const navDirection = input.dataset.navDirection || 'ltr'
    // Trova l'indice nell'array navigabile (che include commaSpot)
    const navIndex = this.allNavigableOrdered.indexOf(input)

    switch (event.key) {
      case 'Backspace':
        if (input.value === '') {
          event.preventDefault()
          // Backspace va nella direzione opposta alla navigazione normale
          const backDirection = navDirection === 'rtl' ? 1 : -1
          this.navigateHorizontal(navIndex, backDirection)
        }
        break

      case 'ArrowLeft':
        event.preventDefault()
        this.navigateHorizontal(navIndex, -1)
        break

      case 'ArrowRight':
        event.preventDefault()
        this.navigateHorizontal(navIndex, 1)
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

  // === Navigation ===

  navigateToNextEnabled(currentIndex, direction) {
    let targetIdx = currentIndex + direction

    // Continua nella direzione finche' non trovi una cella abilitata
    while (targetIdx >= 0 && targetIdx < this.allCellsOrdered.length) {
      const targetCell = this.allCellsOrdered[targetIdx]
      if (!targetCell.disabled && !targetCell.readOnly) {
        targetCell.focus()
        targetCell.select()
        return
      }
      targetIdx += direction
    }
  }

  // Navigazione orizzontale che include anche i commaSpot
  navigateHorizontal(currentIndex, direction) {
    let targetIdx = currentIndex + direction

    while (targetIdx >= 0 && targetIdx < this.allNavigableOrdered.length) {
      const target = this.allNavigableOrdered[targetIdx]

      // Se e' un input, verifica che sia abilitato
      if (target.tagName === 'INPUT') {
        if (!target.disabled && !target.readOnly) {
          target.focus()
          target.select()
          return
        }
      } else {
        // E' un button (commaSpot), sempre navigabile
        target.focus()
        return
      }
      targetIdx += direction
    }
  }

  navigateVertical(currentCell, direction) {
    // Prima prova con data-row/data-col se disponibili
    const currentRow = parseInt(currentCell.dataset.row)
    const currentCol = parseInt(currentCell.dataset.col)

    if (!isNaN(currentRow) && !isNaN(currentCol)) {
      const targetRow = currentRow + direction
      const target = this.element.querySelector(
        `input[data-row="${targetRow}"][data-col="${currentCol}"]`
      )
      if (target && !target.disabled && !target.readOnly) {
        target.focus()
        target.select()
        return
      }
    }

    // Fallback: usa columnMap
    let currentColKey = null
    let currentRowInCol = null

    for (const [col, cells] of Object.entries(this.columnMap)) {
      const rowIndex = cells.indexOf(currentCell)
      if (rowIndex !== -1) {
        currentColKey = parseInt(col)
        currentRowInCol = rowIndex
        break
      }
    }

    if (currentColKey === null || currentRowInCol === null) return

    const columnCells = this.columnMap[currentColKey]
    let targetRow = currentRowInCol + direction

    // Continua nella direzione finche' non trovi una cella abilitata
    while (targetRow >= 0 && targetRow < columnCells.length) {
      const targetCell = columnCells[targetRow]
      if (!targetCell.disabled && !targetCell.readOnly) {
        targetCell.focus()
        targetCell.select()
        return
      }
      targetRow += direction
    }
  }

  // === Comma Actions ===

  toggleComma(event) {
    const spot = event.currentTarget

    // Se questo spot e' gia' attivo, disattivalo
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

  shiftComma(event) {
    const comma = event.currentTarget
    comma.classList.toggle('shifted')
  }

  handleCommaSpotKeydown(event, spot) {
    const navIndex = this.allNavigableOrdered.indexOf(spot)

    switch (event.key) {
      case ' ':
      case 'Enter':
        event.preventDefault()
        this.toggleComma({ currentTarget: spot })
        break
      case 'ArrowLeft':
        event.preventDefault()
        this.navigateHorizontal(navIndex, -1)
        break
      case 'ArrowRight':
        event.preventDefault()
        this.navigateHorizontal(navIndex, 1)
        break
    }
  }

  // === Toolbar Actions ===

  clearGrid() {
    const inputs = this.element.querySelectorAll('input[type="text"]')
    inputs.forEach(input => {
      if (!input.readOnly) {
        input.value = ''
      }
      input.classList.remove('bg-green-100', 'bg-red-100', 'bg-yellow-100',
                            'dark:bg-green-900/50', 'dark:bg-red-900/50', 'dark:bg-yellow-900/50')
      input.classList.add('bg-transparent')

      // Ripristina colore testo per minuendo (sottrazione)
      input.classList.remove('text-gray-300', 'dark:text-gray-600')
      if (input.dataset.quadernoTarget === 'input') {
        input.classList.add('text-gray-800', 'dark:text-gray-100')
      }
    })

    // Pulisci commaSpot
    if (this.hasCommaSpotTarget) {
      this.commaSpotTargets.forEach(spot => {
        spot.classList.remove('active', 'correct', 'incorrect', 'missing')
      })
    }

    // Pulisci commaShift
    if (this.hasCommaShiftTarget) {
      this.commaShiftTargets.forEach(comma => {
        comma.classList.remove('shifted')
      })
    }
  }

  showNumbers() {
    // Mostra gli input (operandi)
    if (this.hasInputTarget) {
      this.inputTargets.forEach(input => {
        const correctAnswer = input.getAttribute('data-correct-answer')
        if (correctAnswer) {
          input.value = correctAnswer
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
          // Sbiadisci minuendo per prestiti sottrazione
          this.handleCarryFade(input, correctAnswer)
        }
      })
    }

    // Mostra i risultati
    if (this.hasResultTarget) {
      this.resultTargets.forEach(input => {
        const correctAnswer = input.getAttribute('data-correct-answer')
        if (correctAnswer) {
          input.value = correctAnswer
        }
      })
    }

    // Mostra la virgola nella posizione corretta
    if (this.hasCommaSpotTarget) {
      this.commaSpotTargets.forEach(spot => {
        spot.classList.remove('active', 'correct', 'incorrect', 'missing')
        if (spot.getAttribute('data-correct-position') === 'true') {
          spot.classList.add('active')
        }
      })
    }

    // Mostra le virgole spostate
    if (this.hasCommaShiftTarget) {
      this.commaShiftTargets.forEach(comma => {
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

      // Salta celle readonly o disabilitate
      if (input.readOnly || input.disabled) {
        return
      }

      // Rimuovi colori precedenti
      input.classList.remove('bg-transparent', 'bg-green-100', 'bg-red-100', 'bg-yellow-100',
                            'dark:bg-green-900/50', 'dark:bg-red-900/50', 'dark:bg-yellow-900/50')

      // Caso: cella deve essere vuota
      if (correctAnswer === '') {
        if (userAnswer === '') {
          input.classList.add('bg-transparent')
        } else {
          input.classList.add('bg-red-100', 'dark:bg-red-900/50')
          hasErrors = true
        }
        return
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

    // Verifica posizione virgola
    const commaCorrect = this.verifyCommaPosition()
    if (!commaCorrect) {
      hasErrors = true
    }

    // Confetti se tutto corretto
    if (correct === total && total > 0 && !hasErrors && commaCorrect) {
      this.jsConfetti.addConfetti({
        emojis: ['🎉', '✨', '🌟', '⭐', '💫'],
        emojiSize: 30,
        confettiNumber: 60
      })
    }
  }

  verifyCommaPosition() {
    if (!this.hasCommaSpotTarget) {
      return true
    }

    const correctSpot = this.commaSpotTargets.find(spot => spot.dataset.correctPosition === 'true')

    if (!correctSpot) {
      // Nessuna virgola richiesta
      const activeSpot = this.commaSpotTargets.find(spot => spot.classList.contains('active'))
      if (activeSpot) {
        activeSpot.classList.add('incorrect')
        return false
      }
      return true
    }

    // C'e' una posizione corretta
    const activeSpot = this.commaSpotTargets.find(spot => spot.classList.contains('active'))

    // Pulisci stati precedenti
    this.commaSpotTargets.forEach(spot => {
      spot.classList.remove('correct', 'incorrect', 'missing')
    })

    if (!activeSpot) {
      correctSpot.classList.add('missing')
      return false
    }

    if (activeSpot === correctSpot) {
      activeSpot.classList.add('correct')
      return true
    } else {
      activeSpot.classList.add('incorrect')
      correctSpot.classList.add('missing')
      return false
    }
  }
}
