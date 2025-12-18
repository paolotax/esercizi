import { Controller } from "@hotwired/stimulus"

// Controller per collegare frasi con linee SVG
export default class extends Controller {
  static targets = ["left", "right", "canvas"]

  connect() {
    this.firstSentence = null
    this.lines = []
    this.setupCanvas()
  }

  setupCanvas() {
    // Ridimensiona il canvas quando necessario
    window.addEventListener('resize', () => this.redrawAllLines())
  }

  selectSentence(event) {
    const clicked = event.currentTarget
    const isLeft = clicked.dataset.side === 'left'

    // Se è il primo click
    if (!this.firstSentence) {
      this.firstSentence = clicked
      clicked.classList.add("ring-4", "ring-yellow-500", "bg-yellow-100")
      return
    }

    // Se clicco di nuovo sullo stesso elemento, deseleziono
    if (this.firstSentence === clicked) {
      this.firstSentence.classList.remove("ring-4", "ring-yellow-500", "bg-yellow-100")
      this.firstSentence = null
      return
    }

    // Controlla che i due click siano su lati opposti
    const firstIsLeft = this.firstSentence.dataset.side === 'left'
    if (firstIsLeft === isLeft) {
      // Entrambi sullo stesso lato, cambia selezione
      this.firstSentence.classList.remove("ring-4", "ring-yellow-500", "bg-yellow-100")
      this.firstSentence = clicked
      clicked.classList.add("ring-4", "ring-yellow-500", "bg-yellow-100")
      return
    }

    // Abbiamo un pairing valido
    const secondSentence = clicked
    this.drawLine(this.firstSentence, secondSentence)

    // Rimuovi highlight
    this.firstSentence.classList.remove("ring-4", "ring-yellow-500", "bg-yellow-100")
    this.firstSentence = null
  }

  drawLine(sentence1, sentence2) {
    const rect1 = sentence1.getBoundingClientRect()
    const rect2 = sentence2.getBoundingClientRect()
    const canvasRect = this.canvasTarget.getBoundingClientRect()

    // Determina quale è left e quale è right
    const leftSentence = sentence1.dataset.side === 'left' ? sentence1 : sentence2
    const rightSentence = sentence1.dataset.side === 'right' ? sentence1 : sentence2
    const leftRect = leftSentence.getBoundingClientRect()
    const rightRect = rightSentence.getBoundingClientRect()

    // Calcola punti: dalla fine del testo a sinistra (right edge) all'inizio del testo a destra (left edge)
    const x1 = leftRect.right - canvasRect.left
    const y1 = leftRect.top + leftRect.height / 2 - canvasRect.top
    const x2 = rightRect.left - canvasRect.left
    const y2 = rightRect.top + rightRect.height / 2 - canvasRect.top

    // Verifica se il pairing è corretto
    const pair1 = sentence1.dataset.pair
    const pair2 = sentence2.dataset.pair
    const isCorrect = pair1 === pair2

    // Crea linea SVG
    const line = document.createElementNS("http://www.w3.org/2000/svg", "line")
    line.setAttribute("x1", x1)
    line.setAttribute("y1", y1)
    line.setAttribute("x2", x2)
    line.setAttribute("y2", y2)
    line.setAttribute("stroke", isCorrect ? "#10b981" : "#ef4444")
    line.setAttribute("stroke-width", "3")
    line.setAttribute("stroke-linecap", "round")

    this.canvasTarget.appendChild(line)

    // Salva info per reset/redraw
    this.lines.push({
      leftSentence: leftSentence,
      rightSentence: rightSentence,
      pair1: pair1,
      pair2: pair2,
      isCorrect: isCorrect,
      element: line
    })
  }

  redrawAllLines() {
    // Ridisegna tutte le linee (es. dopo resize)
    const linesToRedraw = this.lines.slice()
    this.lines = []
    this.canvasTarget.innerHTML = ''

    linesToRedraw.forEach(lineInfo => {
      this.drawLine(lineInfo.leftSentence, lineInfo.rightSentence)
    })
  }

  reset() {
    // Rimuovi tutte le linee
    this.lines.forEach(line => {
      line.element.remove()
    })
    this.lines = []

    // Rimuovi feedback visivo
    this.leftTargets.forEach(s => {
      s.classList.remove("ring-4", "ring-yellow-500", "bg-yellow-100")
    })
    this.rightTargets.forEach(s => {
      s.classList.remove("ring-4", "ring-yellow-500", "bg-yellow-100")
    })

    this.firstSentence = null
  }

  checkAnswers() {
    const totalPairs = this.leftTargets.length

    if (this.lines.length < totalPairs) {
      alert(`Collega tutte le frasi! (${this.lines.length}/${totalPairs})`)
      return
    }

    const correctLines = this.lines.filter(line => line.isCorrect).length

    if (correctLines === totalPairs) {
      alert("🎉 Perfetto! Tutti i collegamenti sono corretti!")
    } else {
      alert(`${correctLines}/${totalPairs} collegamenti corretti. Le linee verdi sono corrette, quelle rosse sono sbagliate.`)
    }
  }
}
