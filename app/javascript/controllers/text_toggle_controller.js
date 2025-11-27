import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "exercise-display-preferences"

export default class extends Controller {
  static targets = ["content", "buttonText"]

  connect() {
    this.loadAndApply()
  }

  loadAndApply() {
    const saved = localStorage.getItem(STORAGE_KEY)
    if (saved) {
      try {
        const prefs = JSON.parse(saved)
        if (prefs.textTransform === "uppercase") {
          this.contentTargets.forEach(c => c.style.textTransform = "uppercase")
          if (this.hasButtonTextTarget) this.buttonTextTarget.textContent = "Aa"
        }
      } catch (e) { /* ignore */ }
    }
  }

  saveTextTransform(value) {
    let prefs = {}
    const saved = localStorage.getItem(STORAGE_KEY)
    if (saved) {
      try { prefs = JSON.parse(saved) } catch (e) { /* ignore */ }
    }
    prefs.textTransform = value
    localStorage.setItem(STORAGE_KEY, JSON.stringify(prefs))
  }

  toggle() {
    const firstContent = this.contentTargets[0]
    const isCurrentlyUppercase = firstContent.style.textTransform === "uppercase"

    this.contentTargets.forEach(content => {
      content.style.textTransform = isCurrentlyUppercase ? "none" : "uppercase"
    })

    if (this.hasButtonTextTarget) {
      this.buttonTextTarget.textContent = isCurrentlyUppercase ? "AA" : "Aa"
    }

    this.saveTextTransform(isCurrentlyUppercase ? "none" : "uppercase")
  }
}
