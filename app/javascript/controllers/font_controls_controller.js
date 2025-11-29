import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "exercise-display-preferences"

export default class extends Controller {
  static targets = ["content", "fontButton"]

  connect() {
    this.loadPreferences()
    this.applyPreferences()
  }

  // Carica preferenze da localStorage
  loadPreferences() {
    const saved = localStorage.getItem(STORAGE_KEY)
    if (saved) {
      try {
        const prefs = JSON.parse(saved)
        this.fontFamily = prefs.fontFamily || "mono"
        this.scaleFactor = prefs.scaleFactor || 1.0
      } catch (e) {
        this.setDefaults()
      }
    } else {
      this.setDefaults()
    }
  }

  setDefaults() {
    this.fontFamily = "mono"
    this.scaleFactor = 1.0
  }

  // Salva preferenze in localStorage
  savePreferences() {
    let prefs = {}
    const saved = localStorage.getItem(STORAGE_KEY)
    if (saved) {
      try { prefs = JSON.parse(saved) } catch (e) { /* ignore */ }
    }
    prefs.fontFamily = this.fontFamily
    prefs.scaleFactor = this.scaleFactor
    localStorage.setItem(STORAGE_KEY, JSON.stringify(prefs))
  }

  // Applica preferenze al DOM
  applyPreferences() {
    this.contentTargets.forEach(content => {
      // Font family
      if (this.fontFamily === "sans") {
        content.style.fontFamily = "ui-sans-serif, system-ui, sans-serif"
      } else {
        content.style.fontFamily = "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New', monospace"
      }
      // Font size
      content.style.fontSize = `${this.scaleFactor * 100}%`
    })
    // Aggiorna pulsante
    if (this.hasFontButtonTarget) {
      this.fontButtonTarget.textContent = this.fontFamily === "mono" ? "F" : "M"
    }
  }

  toggleFont() {
    this.fontFamily = this.fontFamily === "mono" ? "sans" : "mono"
    this.savePreferences()
    this.applyPreferences()
  }

  increase() {
    this.scaleFactor = Math.round((this.scaleFactor + 0.1) * 10) / 10
    this.savePreferences()
    this.applyPreferences()
  }

  decrease() {
    if (this.scaleFactor > 0.5) {
      this.scaleFactor = Math.round((this.scaleFactor - 0.1) * 10) / 10
      this.savePreferences()
      this.applyPreferences()
    }
  }
}
