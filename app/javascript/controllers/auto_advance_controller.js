import { Controller } from "@hotwired/stimulus"

// Auto-advances to next input field when user types a character
// Connects to data-controller="auto-advance"
export default class extends Controller {
  connect() {

    // Add event listeners to auto-advance to next input
    this.element.querySelectorAll('input[type="text"]').forEach((input, index, inputs) => {
      // Auto-advance when a character is typed
      input.addEventListener('input', (e) => {
        // Convert to uppercase
        e.target.value = e.target.value.toUpperCase()

        // Move to next field if this field is at maxlength
        if (e.target.value.length === parseInt(e.target.maxLength) && index < inputs.length - 1) {
          inputs[index + 1].focus()
        }
      })

      // Backspace to go back to previous field
      input.addEventListener('keydown', (e) => {
        if (e.key === 'Backspace' && e.target.value === '' && index > 0) {
          inputs[index - 1].focus()
        }
      })
    })
  }
}
