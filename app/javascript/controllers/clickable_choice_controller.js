import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clickable-choice"
export default class extends Controller {
  static targets = ["option"]

  connect() {
    console.log("Clickable choice controller connected")

    // Add click listeners to all options
    this.optionTargets.forEach(option => {
      option.addEventListener('click', (e) => this.selectOption(e))
    })
  }

  selectOption(event) {
    const clickedOption = event.currentTarget
    const isCorrect = clickedOption.dataset.correct === "true"

    // Find the parent question container
    const questionContainer = clickedOption.closest('.space-y-4')
    const allOptions = questionContainer.querySelectorAll('[data-clickable-choice-target="option"]')

    // Reset all options in this question
    allOptions.forEach(opt => {
      opt.classList.remove('bg-green-200', 'bg-red-200', 'border-green-500', 'border-red-500')
      opt.classList.add('border-blue-300', 'bg-white')
    })

    // Style the clicked option based on correctness
    if (isCorrect) {
      clickedOption.classList.remove('border-blue-300', 'bg-white')
      clickedOption.classList.add('bg-green-200', 'border-green-500')
    } else {
      clickedOption.classList.remove('border-blue-300', 'bg-white')
      clickedOption.classList.add('bg-red-200', 'border-red-500')

      // Also highlight the correct answer
      allOptions.forEach(opt => {
        if (opt.dataset.correct === "true") {
          opt.classList.remove('border-blue-300', 'bg-white')
          opt.classList.add('bg-green-200', 'border-green-500')
        }
      })
    }
  }
}
