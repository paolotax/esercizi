import { Controller } from "@hotwired/stimulus"

// Controller per il drag and drop di frasi nelle textarea
export default class extends Controller {
  static targets = ["phrase", "dropZone"]

  connect() {
    console.log("Phrase drop controller connected")
    this.setupDragAndDrop()
  }

  setupDragAndDrop() {
    // Rendi le frasi draggable
    this.phraseTargets.forEach(phrase => {
      phrase.draggable = true
      phrase.addEventListener('dragstart', (e) => this.handleDragStart(e))
      phrase.addEventListener('dragend', (e) => this.handleDragEnd(e))
      phrase.classList.add('cursor-grab', 'active:cursor-grabbing')
    })

    // Setup drop zones (textarea)
    this.dropZoneTargets.forEach(zone => {
      zone.addEventListener('dragover', (e) => this.handleDragOver(e))
      zone.addEventListener('drop', (e) => this.handleDrop(e))
      zone.addEventListener('dragenter', (e) => this.handleDragEnter(e))
      zone.addEventListener('dragleave', (e) => this.handleDragLeave(e))
    })
  }

  handleDragStart(event) {
    const phrase = event.target.textContent.trim()
    event.dataTransfer.setData('text/plain', phrase)
    event.dataTransfer.effectAllowed = 'copy'
    event.target.classList.add('opacity-50', 'scale-95')
    this.draggedPhrase = event.target
  }

  handleDragEnd(event) {
    event.target.classList.remove('opacity-50', 'scale-95')
    this.draggedPhrase = null
  }

  handleDragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = 'copy'
  }

  handleDragEnter(event) {
    event.preventDefault()
    event.currentTarget.classList.add('ring-4', 'ring-yellow-400', 'bg-yellow-50')
  }

  handleDragLeave(event) {
    if (!event.currentTarget.contains(event.relatedTarget)) {
      event.currentTarget.classList.remove('ring-4', 'ring-yellow-400', 'bg-yellow-50')
    }
  }

  handleDrop(event) {
    event.preventDefault()
    event.currentTarget.classList.remove('ring-4', 'ring-yellow-400', 'bg-yellow-50')

    const phrase = event.dataTransfer.getData('text/plain')
    event.currentTarget.value = phrase

    // Flash verde per conferma
    event.currentTarget.classList.add('ring-4', 'ring-green-400')
    setTimeout(() => {
      event.currentTarget.classList.remove('ring-4', 'ring-green-400')
    }, 500)
  }

  reset() {
    this.dropZoneTargets.forEach(zone => {
      zone.value = ""
      zone.classList.remove('ring-4', 'ring-yellow-400', 'bg-yellow-50', 'ring-green-400')
    })
  }
}
