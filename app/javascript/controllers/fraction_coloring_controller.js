import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="fraction-coloring"
export default class extends Controller {
  static targets = ["part"]
  static values = {
    parts: Number,        // Total number of parts
    toColor: Number       // Number of parts that should be colored
  }

  connect() {
    console.log("Fraction coloring controller connected")
    console.log(`Total parts: ${this.partsValue}, Parts to color: ${this.toColorValue}`)
    this.coloredCount = 0
  }

  togglePart(event) {
    const part = event.currentTarget

    // Check if already colored
    const isColored = part.getAttribute("fill") !== "transparent" && part.getAttribute("fill") !== null && part.getAttribute("fill") !== ""

    if (isColored) {
      // Uncolor it
      part.setAttribute("fill", "transparent")
      this.coloredCount--
    } else {
      // Color it
      part.setAttribute("fill", "#FDA4AF")  // Pink color
      this.coloredCount++
    }

    console.log(`Colored parts: ${this.coloredCount}/${this.toColorValue}`)
  }

  checkAnswers() {
    // This is called by the exercise-checker controller
    const isCorrect = this.coloredCount === this.toColorValue
    return {
      correct: isCorrect,
      coloredCount: this.coloredCount,
      expectedCount: this.toColorValue
    }
  }

  showSolution() {
    // Color the correct number of parts
    this.partTargets.forEach((part, index) => {
      if (index < this.toColorValue) {
        part.setAttribute("fill", "#86EFAC")  // Green color for solution
      } else {
        part.setAttribute("fill", "transparent")
      }
    })
    this.coloredCount = this.toColorValue
  }

  reset() {
    // Clear all colors
    this.partTargets.forEach(part => {
      part.setAttribute("fill", "transparent")
    })
    this.coloredCount = 0
  }
}
