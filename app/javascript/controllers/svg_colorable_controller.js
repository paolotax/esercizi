import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="svg-colorable"
export default class extends Controller {
  static targets = ["cell"]
  static values = {
    color: { type: String, default: "#93c5fd" },      // colore attivo (default: blue-300)
    defaultColor: { type: String, default: "white" }  // colore di default
  }

  connect() {
    console.log("SVG Colorable controller connected")
    console.log("Active color:", this.colorValue)
    console.log("Default color:", this.defaultColorValue)
  }

  toggleCell(event) {
    const cell = event.currentTarget

    if (cell.tagName === 'path' || cell.tagName === 'rect' || cell.tagName === 'circle' || cell.tagName === 'polygon' || cell.tagName === 'ellipse') {
      const currentFill = cell.getAttribute('fill')

      // Se la cella ha il colore di default, applica il colore attivo
      if (this.isDefaultColor(currentFill)) {
        cell.setAttribute('fill', this.colorValue)
      } else {
        // Altrimenti riporta al colore di default
        cell.setAttribute('fill', this.defaultColorValue)
      }
    }
  }

  isDefaultColor(color) {
    // Normalizza i colori per il confronto
    const normalizedColor = color?.toLowerCase().trim()
    const normalizedDefault = this.defaultColorValue.toLowerCase().trim()

    return normalizedColor === normalizedDefault ||
           normalizedColor === '#ffffff' && normalizedDefault === 'white' ||
           normalizedColor === 'white' && normalizedDefault === '#ffffff'
  }

  // Metodo per cambiare il colore attivo dinamicamente
  setColor(newColor) {
    this.colorValue = newColor
  }

  // Metodo per resettare tutte le celle
  reset() {
    this.cellTargets.forEach(cell => {
      if (cell.tagName === 'path' || cell.tagName === 'rect' || cell.tagName === 'circle' || cell.tagName === 'polygon' || cell.tagName === 'ellipse') {
        cell.setAttribute('fill', this.defaultColorValue)
      }
    })
  }
}
