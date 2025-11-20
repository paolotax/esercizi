import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="copy-to-clipboard"
export default class extends Controller {
  copy(event) {
    const button = event.currentTarget
    const text = button.dataset.copyToClipboardTextParam

    // Copia nel clipboard
    navigator.clipboard.writeText(text).then(() => {
      // Feedback visivo
      const originalText = button.textContent
      button.textContent = "Copiato!"
      button.classList.remove("bg-cyan-500", "hover:bg-cyan-600")
      button.classList.add("bg-green-500", "hover:bg-green-600")

      // Ripristina dopo 2 secondi
      setTimeout(() => {
        button.textContent = originalText
        button.classList.remove("bg-green-500", "hover:bg-green-600")
        button.classList.add("bg-cyan-500", "hover:bg-cyan-600")
      }, 2000)
    }).catch(err => {
      console.error("Errore durante la copia:", err)
      button.textContent = "Errore"
      setTimeout(() => {
        button.textContent = "Copia"
      }, 2000)
    })
  }
}
