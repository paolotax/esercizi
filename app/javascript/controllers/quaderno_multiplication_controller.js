import { Controller } from "@hotwired/stimulus"
import JSConfetti from "js-confetti"

/**
 * Controller per il quaderno di moltiplicazioni
 * Gestisce la navigazione tra celle, verifica delle risposte e feedback visivo
 */
export default class extends Controller {
  static targets = ["multiplicand", "multiplier", "result", "carry", "partial", "partialCarry", "sumCarry", "commaSpot"]

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
      cell.addEventListener('keydown', (e) => this.handleResultKeydown(e, index))
    })

    // Aggiungi navigazione keyboard ai commaSpot
    if (this.hasCommaSpotTarget) {
      this.commaSpotTargets.forEach((spot) => {
        spot.addEventListener('keydown', (e) => this.handleCommaSpotKeydown(e, spot))
      })
    }

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

    if (this.hasPartialCarryTarget) {
      this.partialCarryTargets.forEach((cell, index) => {
        cell.addEventListener('input', (e) => this.handleCellInput(e, index, 'partialCarry'))
        cell.addEventListener('keydown', (e) => this.handleCellKeydown(e, index, 'partialCarry'))
      })
    }

    if (this.hasSumCarryTarget) {
      this.sumCarryTargets.forEach((cell, index) => {
        cell.addEventListener('input', (e) => this.handleCarryInput(e, index))
        cell.addEventListener('keydown', (e) => this.handleCarryKeydown(e, index, 'sumCarry'))
      })
    }
  }

  buildCellGrid() {
    const grid = this.element.querySelector('.inline-grid')

    if (!grid) {
      this.columnMap = {}
      this.allCellsOrdered = []
      return
    }

    // Raccogli tutte le celle input in ordine DOM
    const allCells = grid.querySelectorAll(
      '[data-quaderno-multiplication-target="multiplicand"], [data-quaderno-multiplication-target="multiplier"], [data-quaderno-multiplication-target="result"], [data-quaderno-multiplication-target="carry"], [data-quaderno-multiplication-target="partial"], [data-quaderno-multiplication-target="partialCarry"], [data-quaderno-multiplication-target="sumCarry"]'
    )

    // Mappa colonne per navigazione verticale
    this.columnMap = {}

    // Calcola il numero di colonne dalla griglia CSS
    const gridStyle = window.getComputedStyle(grid)
    const cols = gridStyle.gridTemplateColumns.split(' ').length

    // Array con tutte le celle e le loro posizioni per ordinamento
    const cellsWithPositions = []

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
      this.columnMap[col].push(cell)

      // Salva per ordinamento globale
      cellsWithPositions.push({ cell, gridIndex })
    })

    // Crea lista ordinata di tutte le celle (riga per riga, da sinistra a destra)
    cellsWithPositions.sort((a, b) => a.gridIndex - b.gridIndex)
    this.allCellsOrdered = cellsWithPositions.map(item => item.cell)
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
      else if (type === 'partialCarry') cells = this.partialCarryTargets
      else cells = this.resultTargets

      if (type === 'result' || type === 'partial' || type === 'partialCarry') {
        // Nel risultato/partial/partialCarry, naviga da destra a sinistra
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

    // Per partial e partialCarry usa sempre navigazione globale
    // perché i target sono concatenati da più righe
    if (type === 'partial' || type === 'partialCarry') {
      switch (event.key) {
        case 'Backspace':
          if (input.value === '') {
            event.preventDefault()
            // Backspace va a destra (direzione inversa)
            this.navigateGlobal(input, 1)
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

        case 'ArrowUp':
          event.preventDefault()
          this.navigateVertical(input, -1)
          break

        case 'ArrowDown':
          event.preventDefault()
          this.navigateVertical(input, 1)
          break
      }
      return
    }

    // Per multiplicand e multiplier, usa navigazione per array di tipo
    const cells = type === 'multiplicand' ? this.multiplicandTargets : this.multiplierTargets

    switch (event.key) {
      case 'Backspace':
        if (input.value === '') {
          event.preventDefault()
          // Nel moltiplicando/moltiplicatore, backspace va a sinistra
          if (currentIndex > 0) {
            cells[currentIndex - 1].focus()
            cells[currentIndex - 1].select()
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

  // Costruisce la sequenza ordinata di elementi nella riga risultato (input + commaSpot)
  // Ordine: da sinistra a destra nella griglia
  getResultRowElements() {
    const elements = []

    this.resultTargets.forEach((input, idx) => {
      elements.push({ type: 'result', element: input, index: idx })

      // Cerca il commaSpot associato a questa cella (è dentro lo stesso parent div)
      if (this.hasCommaSpotTarget) {
        const parentDiv = input.parentElement
        const spot = parentDiv.querySelector('[data-quaderno-multiplication-target="commaSpot"]')
        if (spot) {
          elements.push({ type: 'commaSpot', element: spot, index: idx })
        }
      }
    })

    return elements
  }

  // Gestione keydown specifica per la riga risultato (include navigazione sui commaSpot)
  handleResultKeydown(event, currentIndex) {
    const input = event.target

    switch (event.key) {
      case 'Backspace':
        if (input.value === '') {
          event.preventDefault()
          // Nel risultato, backspace va a destra
          if (currentIndex < this.resultTargets.length - 1) {
            this.resultTargets[currentIndex + 1].focus()
            this.resultTargets[currentIndex + 1].select()
          }
        }
        break

      case 'ArrowLeft':
        event.preventDefault()
        this.navigateResultRow(input, -1)
        break

      case 'ArrowRight':
        event.preventDefault()
        this.navigateResultRow(input, 1)
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

  // Gestione keydown per commaSpot
  handleCommaSpotKeydown(event, spot) {
    switch (event.key) {
      case 'ArrowLeft':
        event.preventDefault()
        this.navigateResultRow(spot, -1)
        break

      case 'ArrowRight':
        event.preventDefault()
        this.navigateResultRow(spot, 1)
        break

      case ' ':
      case 'Enter':
        // Spazio o Enter attiva/disattiva la virgola
        event.preventDefault()
        this.toggleComma({ currentTarget: spot })
        break
    }
  }

  // Naviga nella riga risultato includendo i commaSpot
  navigateResultRow(currentElement, direction) {
    const elements = this.getResultRowElements()
    const currentIdx = elements.findIndex(el => el.element === currentElement)

    if (currentIdx === -1) return

    const targetIdx = currentIdx + direction
    if (targetIdx >= 0 && targetIdx < elements.length) {
      const target = elements[targetIdx]
      target.element.focus()
      if (target.type === 'result') {
        target.element.select()
      }
    } else {
      // Siamo al bordo della riga risultato, naviga alla riga successiva/precedente
      this.navigateGlobal(currentElement, direction)
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
  // Salta le celle disabilitate (come lo 0 nell'ultima colonna dei riporti)
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
    let targetRow = currentRowInCol + direction

    // Continua nella direzione finché non trovi una cella abilitata o esci dai limiti
    while (targetRow >= 0 && targetRow < columnCells.length) {
      const targetCell = columnCells[targetRow]
      // Salta celle disabilitate
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
      // Dopo aver digitato, vai al moltiplicando nella stessa colonna
      if (currentIndex < this.multiplicandTargets.length) {
        this.multiplicandTargets[currentIndex].focus()
        this.multiplicandTargets[currentIndex].select()
      }
    }
  }

  handleCarryKeydown(event, currentIndex, type = 'carry') {
    const input = event.target

    // Usa sempre navigazione globale per i carry
    // perché devono poter passare alla riga successiva (risultato, moltiplicando, ecc.)
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

  // === Comma Spot Actions ===

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

  // === Toolbar Actions ===

  clearGrid() {
    const inputs = this.element.querySelectorAll('input')
    inputs.forEach(input => {
      input.value = ''
      input.classList.remove('bg-green-100', 'bg-red-100', 'bg-yellow-100', 'dark:bg-green-900/50', 'dark:bg-red-900/50', 'dark:bg-yellow-900/50')
      input.classList.add('bg-transparent')
    })

    // Pulisci anche gli spot virgola
    if (this.hasCommaSpotTarget) {
      this.commaSpotTargets.forEach(spot => {
        spot.classList.remove('active', 'correct', 'incorrect', 'missing')
      })
    }
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

    // Mostra i riporti dei prodotti parziali
    if (this.hasPartialCarryTarget) {
      this.partialCarryTargets.forEach(input => {
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

    // Mostra la virgola nella posizione corretta
    if (this.hasCommaSpotTarget) {
      this.commaSpotTargets.forEach(spot => {
        spot.classList.remove('active', 'correct', 'incorrect', 'missing')
        if (spot.getAttribute('data-correct-position') === 'true') {
          spot.classList.add('active')
        }
      })
    }
  }

  verifyAnswers() {
    // Raccogli tutti gli input
    const carries = this.hasCarryTarget ? Array.from(this.carryTargets) : []
    const partials = this.hasPartialTarget ? Array.from(this.partialTargets) : []
    const partialCarries = this.hasPartialCarryTarget ? Array.from(this.partialCarryTargets) : []
    const sumCarries = this.hasSumCarryTarget ? Array.from(this.sumCarryTargets) : []
    const allInputs = [...carries, ...partialCarries, ...this.multiplicandTargets, ...this.multiplierTargets, ...partials, ...sumCarries, ...this.resultTargets]

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

    // Verifica posizione virgola nel risultato
    if (this.hasCommaSpotTarget) {
      let commaCorrect = false
      let commaPlaced = false
      let hasCorrectPosition = false

      this.commaSpotTargets.forEach(spot => {
        const isCorrectPosition = spot.getAttribute('data-correct-position') === 'true'
        const isActive = spot.classList.contains('active')

        // Rimuovi classi precedenti
        spot.classList.remove('correct', 'incorrect', 'missing')

        if (isCorrectPosition) {
          hasCorrectPosition = true
        }

        if (isActive) {
          commaPlaced = true
          if (isCorrectPosition) {
            // Virgola nella posizione corretta
            spot.classList.add('correct')
            commaCorrect = true
          } else {
            // Virgola nella posizione sbagliata
            spot.classList.add('incorrect')
            hasErrors = true
          }
        } else if (isCorrectPosition) {
          // La posizione corretta non è stata selezionata
          spot.classList.add('missing')
        }
      })

      // Conta la virgola come elemento da verificare se ci sono decimali
      if (hasCorrectPosition) {
        total++
        if (commaCorrect) {
          correct++
        } else if (!commaPlaced) {
          // Virgola non inserita - non è un errore grave, solo mancante
        } else {
          // Virgola inserita ma in posizione sbagliata - già segnato come errore sopra
        }
      }
    }

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
