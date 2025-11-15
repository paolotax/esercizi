import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="number-line"
export default class extends Controller {
  static targets = ["numberButton", "feedback"]

  connect() {
    console.log("Number line controller connected")
    this.selectedNumbers = new Set()
  }

  toggleNumber(event) {
    const button = event.currentTarget
    const number = parseInt(button.dataset.number)
    const isCorrect = button.dataset.correct === "true"

    // Toggle selection
    if (this.selectedNumbers.has(number)) {
      this.selectedNumbers.delete(number)
      button.classList.remove('selected')
    } else {
      this.selectedNumbers.add(number)
      button.classList.add('selected')
    }

    // Check if the exercise is complete
    this.checkCompletion()
  }

  checkCompletion() {
    // Get all correct numbers
    const correctNumbers = this.numberButtonTargets
      .filter(button => button.dataset.correct === "true")
      .map(button => parseInt(button.dataset.number))

    // Check if all correct numbers are selected
    const allCorrectSelected = correctNumbers.every(num =>
      this.selectedNumbers.has(num)
    )

    // Check if no incorrect numbers are selected
    const noIncorrectSelected = Array.from(this.selectedNumbers).every(num =>
      correctNumbers.includes(num)
    )

    // Show feedback
    if (this.hasFeedbackTarget) {
      if (allCorrectSelected && noIncorrectSelected) {
        this.feedbackTarget.textContent = "Ottimo lavoro! Hai cerchiato i numeri corretti!"
        this.feedbackTarget.className = "text-green-600 font-bold text-lg"
        this.feedbackTarget.classList.remove('hidden')
      } else if (this.selectedNumbers.size > 0) {
        this.feedbackTarget.textContent = "Continua... seleziona i numeri corretti"
        this.feedbackTarget.className = "text-blue-600 font-semibold text-lg"
        this.feedbackTarget.classList.remove('hidden')
      } else {
        this.feedbackTarget.classList.add('hidden')
      }
    }
  }
}
