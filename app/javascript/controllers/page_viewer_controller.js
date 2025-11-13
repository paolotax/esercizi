import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="page-viewer"
export default class extends Controller {
  static values = {
    imageUrl: String
  }

  openOriginal() {
    if (this.imageUrlValue) {
      // Apre l'immagine PNG originale in una nuova finestra
      window.open(this.imageUrlValue, '_blank', 'width=1200,height=900')
    }
  }
}
