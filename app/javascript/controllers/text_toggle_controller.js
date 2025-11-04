import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "buttonText"]

  toggle() {
    // Check the first content target to determine current state
    const firstContent = this.contentTargets[0]
    const isCurrentlyUppercase = firstContent.style.textTransform === "uppercase"

    // Apply to all content targets
    this.contentTargets.forEach(content => {
      if (isCurrentlyUppercase) {
        // Torna normale
        content.style.textTransform = "none"
      } else {
        // Passa a maiuscolo
        content.style.textTransform = "uppercase"
      }
    })

    // Update button text
    if (this.hasButtonTextTarget) {
      this.buttonTextTarget.textContent = isCurrentlyUppercase ? "MAIUSCOLO" : "minuscolo"
    }
  }
}
