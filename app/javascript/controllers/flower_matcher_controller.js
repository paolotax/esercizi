import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flower-matcher"
export default class extends Controller {
  static targets = ["flower", "canvas"]

  connect() {
    console.log("Flower matcher controller connected")
    this.firstFlower = null
    this.lines = []
  }

  selectFlower(event) {
    const clickedFlower = event.currentTarget

    // If this is the first flower
    if (!this.firstFlower) {
      this.firstFlower = clickedFlower
      clickedFlower.classList.add("ring-4", "ring-orange-500")
      return
    }

    // If clicking the same flower, deselect it
    if (this.firstFlower === clickedFlower) {
      this.firstFlower.classList.remove("ring-4", "ring-orange-500")
      this.firstFlower = null
      return
    }

    // This is the second flower - draw a line
    const secondFlower = clickedFlower
    this.drawLine(this.firstFlower, secondFlower)

    // Remove highlight from first flower
    this.firstFlower.classList.remove("ring-4", "ring-orange-500")
    this.firstFlower = null
  }

  drawLine(flower1, flower2) {
    const rect1 = flower1.getBoundingClientRect()
    const rect2 = flower2.getBoundingClientRect()
    const canvasRect = this.canvasTarget.getBoundingClientRect()

    // Calculate center points relative to canvas
    const x1 = rect1.left + rect1.width / 2 - canvasRect.left
    const y1 = rect1.top + rect1.height / 2 - canvasRect.top
    const x2 = rect2.left + rect2.width / 2 - canvasRect.left
    const y2 = rect2.top + rect2.height / 2 - canvasRect.top

    // Check if pairing is correct
    const pair1 = flower1.dataset.pair
    const pair2 = flower2.dataset.pair
    const isCorrect = pair1 === pair2

    // Create SVG line
    const line = document.createElementNS("http://www.w3.org/2000/svg", "line")
    line.setAttribute("x1", x1)
    line.setAttribute("y1", y1)
    line.setAttribute("x2", x2)
    line.setAttribute("y2", y2)
    line.setAttribute("stroke", isCorrect ? "#10b981" : "#ef4444")
    line.setAttribute("stroke-width", "4")
    line.setAttribute("stroke-linecap", "round")

    this.canvasTarget.appendChild(line)

    // Store line info for checking later
    this.lines.push({
      flower1: flower1.dataset.flowerId,
      flower2: flower2.dataset.flowerId,
      pair1: pair1,
      pair2: pair2,
      isCorrect: isCorrect,
      element: line
    })

    // Visual feedback is provided by the line color only
    // No borders needed after connection
  }

  reset() {
    // Remove all lines
    this.lines.forEach(line => {
      line.element.remove()
    })
    this.lines = []

    // Remove all visual feedback
    this.flowerTargets.forEach(flower => {
      flower.classList.remove("ring-4", "ring-orange-500")
    })

    this.firstFlower = null
  }

  checkAnswers() {
    // Check if all flowers are paired
    const totalFlowers = this.flowerTargets.length
    const expectedPairs = totalFlowers / 2

    if (this.lines.length < expectedPairs) {
      return {
        complete: false,
        correct: 0,
        total: expectedPairs,
        message: `Collega tutti i fiori! (${this.lines.length}/${expectedPairs})`
      }
    }

    const correctLines = this.lines.filter(line => line.isCorrect).length

    return {
      complete: true,
      correct: correctLines,
      total: expectedPairs,
      allCorrect: correctLines === expectedPairs,
      message: correctLines === expectedPairs
        ? "Tutti i collegamenti sono corretti!"
        : `${correctLines}/${expectedPairs} collegamenti corretti`
    }
  }
}
