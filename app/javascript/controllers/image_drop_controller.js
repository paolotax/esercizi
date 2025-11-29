import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image-drop"
// Drag & drop di immagini su hotspot
export default class extends Controller {
  static targets = ["draggable", "dropZone"]

  connect() {
    console.log("Image drop controller connected")
    this.setupDragAndDrop()
  }

  setupDragAndDrop() {
    // Make images draggable
    this.draggableTargets.forEach(item => {
      item.draggable = true
      item.addEventListener('dragstart', (e) => this.handleDragStart(e))
      item.addEventListener('dragend', (e) => this.handleDragEnd(e))
      item.classList.add('cursor-grab', 'active:cursor-grabbing')
    })

    // Setup drop zones
    this.dropZoneTargets.forEach(zone => {
      zone.addEventListener('dragover', (e) => this.handleDragOver(e))
      zone.addEventListener('drop', (e) => this.handleDrop(e))
      zone.addEventListener('dragenter', (e) => this.handleDragEnter(e))
      zone.addEventListener('dragleave', (e) => this.handleDragLeave(e))
    })
  }

  handleDragStart(event) {
    const item = event.currentTarget
    const value = item.dataset.imageDropValue
    const imageSrc = item.dataset.imageSrc

    event.dataTransfer.setData('text/plain', value)
    event.dataTransfer.setData('image-src', imageSrc)
    event.dataTransfer.effectAllowed = 'move'

    item.classList.add('opacity-50', 'scale-95')
    this.draggedItem = item
  }

  handleDragEnd(event) {
    event.currentTarget.classList.remove('opacity-50', 'scale-95')
    this.draggedItem = null
  }

  handleDragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = 'move'
  }

  handleDragEnter(event) {
    event.preventDefault()
    event.currentTarget.classList.add('bg-blue-200/50', 'border-blue-500', 'scale-105')
  }

  handleDragLeave(event) {
    if (!event.currentTarget.contains(event.relatedTarget)) {
      event.currentTarget.classList.remove('bg-blue-200/50', 'border-blue-500', 'scale-105')
    }
  }

  handleDrop(event) {
    event.preventDefault()
    const zone = event.currentTarget
    zone.classList.remove('bg-blue-200/50', 'border-blue-500', 'scale-105')

    const value = event.dataTransfer.getData('text/plain')
    const imageSrc = event.dataTransfer.getData('image-src')

    // Clear previous content
    zone.innerHTML = ''

    // Try to show image, fallback to letter
    if (imageSrc) {
      const img = document.createElement('img')
      img.src = imageSrc
      img.className = 'max-h-8 max-w-full mx-auto object-contain'
      img.alt = value
      img.onerror = () => {
        // Fallback to letter if image fails
        zone.innerHTML = `<span class="text-sm font-bold text-gray-700">${value}</span>`
      }
      zone.appendChild(img)
    } else {
      zone.innerHTML = `<span class="text-sm font-bold text-gray-700">${value}</span>`
    }

    // Store the value for checking
    zone.dataset.droppedValue = value

    // Style the filled zone
    zone.classList.add('bg-white/80', 'border-green-500')
    zone.classList.remove('border-dashed')

    // Mark the dragged item as used
    if (this.draggedItem) {
      this.draggedItem.classList.remove('opacity-50', 'scale-95')
      this.draggedItem.classList.add('opacity-40', 'grayscale')
      this.draggedItem.draggable = false

      // Add used indicator
      if (!this.draggedItem.querySelector('.used-indicator')) {
        const indicator = document.createElement('span')
        indicator.className = 'used-indicator absolute top-0 right-0 text-green-600 font-bold text-lg'
        indicator.textContent = '✓'
        this.draggedItem.style.position = 'relative'
        this.draggedItem.appendChild(indicator)
      }

      this.draggedItem = null
    }
  }

  checkAnswers(event) {
    if (event) event.preventDefault()

    let correctCount = 0
    let incorrectCount = 0
    let emptyCount = 0

    this.dropZoneTargets.forEach(zone => {
      const correctAnswer = zone.dataset.correctAnswer?.trim().toLowerCase()
      const droppedValue = zone.dataset.droppedValue?.trim().toLowerCase()

      // Remove previous styling
      zone.classList.remove('border-green-500', 'border-red-500', 'border-yellow-500',
                           'bg-green-100', 'bg-red-100', 'bg-yellow-100')

      if (!droppedValue) {
        emptyCount++
        zone.classList.add('border-yellow-500', 'bg-yellow-100/50')
      } else if (droppedValue === correctAnswer) {
        correctCount++
        zone.classList.add('border-green-500', 'bg-green-100/50')
      } else {
        incorrectCount++
        zone.classList.add('border-red-500', 'bg-red-100/50')
        // Shake animation
        zone.classList.add('animate-shake')
        setTimeout(() => zone.classList.remove('animate-shake'), 500)
      }
    })

    const allCorrect = incorrectCount === 0 && emptyCount === 0
    this.showFeedback(allCorrect, correctCount, incorrectCount, emptyCount)
  }

  showFeedback(allCorrect, correctCount, incorrectCount, emptyCount) {
    const existingFeedback = this.element.querySelector('.image-drop-feedback')
    if (existingFeedback) existingFeedback.remove()

    const feedbackDiv = document.createElement('div')
    feedbackDiv.className = 'image-drop-feedback mt-6 p-6 rounded-lg shadow-lg ' +
                           (allCorrect ? 'bg-green-100 border-4 border-green-500' : 'bg-orange-100 border-4 border-orange-500')

    const title = document.createElement('h2')
    title.className = 'text-2xl font-bold mb-4 ' + (allCorrect ? 'text-green-800' : 'text-orange-800')
    title.textContent = allCorrect ? '🎉 Eccellente! Tutte le risposte sono corrette!' : '📝 Controlla le risposte evidenziate'

    const stats = document.createElement('div')
    stats.className = 'text-lg space-y-2'
    stats.innerHTML = `
      ${correctCount > 0 ? `<p class="text-green-700">✅ Corrette: ${correctCount}</p>` : ''}
      ${incorrectCount > 0 ? `<p class="text-red-700">❌ Errate: ${incorrectCount}</p>` : ''}
      ${emptyCount > 0 ? `<p class="text-yellow-700">⚠️ Da completare: ${emptyCount}</p>` : ''}
    `

    feedbackDiv.appendChild(title)
    feedbackDiv.appendChild(stats)

    if (!allCorrect) {
      const retryButton = document.createElement('button')
      retryButton.className = 'mt-4 bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-6 rounded-full transition'
      retryButton.textContent = '🔄 Riprova'
      retryButton.onclick = () => this.reset()
      feedbackDiv.appendChild(retryButton)
    }

    this.element.appendChild(feedbackDiv)
    feedbackDiv.scrollIntoView({ behavior: 'smooth', block: 'center' })
  }

  reset() {
    // Reset drop zones
    this.dropZoneTargets.forEach(zone => {
      zone.innerHTML = ''
      delete zone.dataset.droppedValue
      zone.classList.remove('border-green-500', 'border-red-500', 'border-yellow-500',
                           'bg-green-100', 'bg-red-100', 'bg-yellow-100', 'bg-white/80',
                           'bg-green-100/50', 'bg-red-100/50', 'bg-yellow-100/50')
      zone.classList.add('border-dashed')
    })

    // Reset draggable items
    this.draggableTargets.forEach(item => {
      item.classList.remove('opacity-40', 'grayscale', 'opacity-50', 'scale-95')
      item.draggable = true

      const indicator = item.querySelector('.used-indicator')
      if (indicator) indicator.remove()
    })

    // Remove feedback
    const feedback = this.element.querySelector('.image-drop-feedback')
    if (feedback) feedback.remove()
  }
}
