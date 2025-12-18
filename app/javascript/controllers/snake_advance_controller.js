import { Controller } from "@hotwired/stimulus"

// Auto-advances following snake pattern (0→1...→9→19→18...→10→20→21...)
// Connects to data-controller="snake-advance"
export default class extends Controller {
  static targets = ["input"]

  connect() {

    // Create a map of inputs by their correct answer (number value)
    this.inputMap = new Map()
    this.inputTargets.forEach(input => {
      const number = parseInt(input.dataset.correctAnswer)
      this.inputMap.set(number, input)
    })

    // Add event listeners to each input
    this.inputTargets.forEach(input => {
      const currentNumber = parseInt(input.dataset.correctAnswer)

      // Auto-advance when maxlength is reached
      input.addEventListener('input', (e) => {
        const maxLen = parseInt(e.target.maxLength)

        if (e.target.value.length === maxLen) {
          // Find next available input (skip prefilled numbers)
          let nextNumber = currentNumber + 1
          let nextInput = null

          // Try to find next input within reasonable range (up to 5 numbers ahead)
          for (let i = 0; i < 5 && !nextInput; i++) {
            nextInput = this.inputMap.get(nextNumber + i)
          }

          if (nextInput) {
            nextInput.focus()
          }
        }
      })

      // Backspace to go to previous number in snake sequence
      input.addEventListener('keydown', (e) => {
        if (e.key === 'Backspace' && e.target.value === '') {
          // Find previous available input (skip prefilled numbers)
          let prevNumber = currentNumber - 1
          let prevInput = null

          // Try to find previous input within reasonable range (up to 5 numbers back)
          for (let i = 0; i < 5 && !prevInput; i++) {
            prevInput = this.inputMap.get(prevNumber - i)
          }

          if (prevInput) {
            e.preventDefault()
            prevInput.focus()
          }
        }
      })
    })
  }
}
