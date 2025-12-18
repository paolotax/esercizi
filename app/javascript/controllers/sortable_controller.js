import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sortable"
// Generic drag-and-drop sortable controller for numbers, text, images, cards
// Integrates with exercise-checker via hidden inputs with data-correct-answer
export default class extends Controller {
  static targets = ["container", "item"]
  static values = {
    mode: { type: String, default: "sequence" } // "numeric-asc", "numeric-desc", "sequence"
  }

  connect() {
    this.setupDragAndDrop()
    this.createHiddenInputs()
    this.shuffleItems()
  }

  setupDragAndDrop() {
    this.itemTargets.forEach(item => {
      item.draggable = true
      item.classList.add('cursor-grab')

      item.addEventListener('dragstart', (e) => this.handleDragStart(e))
      item.addEventListener('dragend', (e) => this.handleDragEnd(e))
      item.addEventListener('dragover', (e) => this.handleDragOver(e))
      item.addEventListener('dragenter', (e) => this.handleDragEnter(e))
      item.addEventListener('dragleave', (e) => this.handleDragLeave(e))
      item.addEventListener('drop', (e) => this.handleDrop(e))

      // Touch support for mobile
      item.addEventListener('touchstart', (e) => this.handleTouchStart(e), { passive: false })
      item.addEventListener('touchmove', (e) => this.handleTouchMove(e), { passive: false })
      item.addEventListener('touchend', (e) => this.handleTouchEnd(e))
    })
  }

  shuffleItems() {
    const container = this.containerTarget
    const items = [...this.itemTargets]

    // Fisher-Yates shuffle
    for (let i = items.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1))
      ;[items[i], items[j]] = [items[j], items[i]]
    }

    // Re-append items in shuffled order
    items.forEach(item => container.appendChild(item))

    // Update hidden inputs
    this.updateHiddenInputs()
  }

  createHiddenInputs() {
    // Get correct order based on mode
    const correctOrder = this.getCorrectOrder()

    // Create container for hidden inputs
    this.inputsContainer = document.createElement('div')
    this.inputsContainer.className = 'hidden'
    this.element.appendChild(this.inputsContainer)

    // Create one hidden input for each position
    correctOrder.forEach((correctValue, index) => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.dataset.correctAnswer = correctValue
      input.dataset.position = index
      this.inputsContainer.appendChild(input)
    })

    this.updateHiddenInputs()
  }

  getCorrectOrder() {
    const items = this.itemTargets

    if (this.modeValue === 'numeric-asc') {
      // Sort by numeric value ascending
      return [...items]
        .sort((a, b) => this.getNumericValue(a) - this.getNumericValue(b))
        .map(item => this.getIdentifier(item))
    } else if (this.modeValue === 'numeric-desc') {
      // Sort by numeric value descending
      return [...items]
        .sort((a, b) => this.getNumericValue(b) - this.getNumericValue(a))
        .map(item => this.getIdentifier(item))
    } else {
      // Sequence mode: use data-sortable-position
      return [...items]
        .sort((a, b) => parseInt(a.dataset.sortablePosition || 0) - parseInt(b.dataset.sortablePosition || 0))
        .map(item => this.getIdentifier(item))
    }
  }

  getNumericValue(item) {
    // Get numeric value from data attribute or text content
    if (item.dataset.sortableValue) {
      return parseFloat(item.dataset.sortableValue)
    }
    // Fallback: parse text content (remove spaces)
    const text = item.textContent.trim().replace(/\s/g, '')
    return parseFloat(text) || 0
  }

  getIdentifier(item) {
    // Use data-sortable-value or data-sortable-position as identifier
    return item.dataset.sortableValue || item.dataset.sortablePosition || item.textContent.trim()
  }

  updateHiddenInputs() {
    const currentOrder = this.itemTargets.map(item => this.getIdentifier(item))
    const inputs = this.inputsContainer.querySelectorAll('input')

    inputs.forEach((input, index) => {
      input.value = currentOrder[index] || ''
    })
  }

  handleDragStart(event) {
    this.draggedElement = event.target.closest('[data-sortable-target="item"]')

    // Clear all feedback colors when starting a new drag
    this.itemTargets.forEach(item => {
      item.classList.remove('border-green-500', 'border-red-500', 'bg-green-50', 'bg-red-50')
      item.classList.add('border-cyan-400', 'bg-transparent')
    })

    this.draggedElement.classList.add('opacity-50', 'cursor-grabbing')
    this.draggedElement.classList.remove('cursor-grab')

    event.dataTransfer.effectAllowed = 'move'
    event.dataTransfer.setData('text/plain', '')
  }

  handleDragEnd(event) {
    const item = event.target.closest('[data-sortable-target="item"]')
    item.classList.remove('opacity-50', 'cursor-grabbing')
    item.classList.add('cursor-grab')

    // Remove drag-over styling and restore original border color
    this.itemTargets.forEach(i => {
      i.classList.remove('scale-105', 'border-blue-500', 'bg-blue-50')
      // Restore cyan border if no feedback color is present
      if (!i.classList.contains('border-green-500') && !i.classList.contains('border-red-500')) {
        i.classList.add('border-cyan-400')
      }
    })

    this.draggedElement = null
    this.updateHiddenInputs()
  }

  handleDragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = 'move'
  }

  handleDragEnter(event) {
    event.preventDefault()
    const item = event.target.closest('[data-sortable-target="item"]')
    if (item && item !== this.draggedElement) {
      item.classList.remove('border-cyan-400')
      item.classList.add('scale-105', 'border-blue-500')
    }
  }

  handleDragLeave(event) {
    const item = event.target.closest('[data-sortable-target="item"]')
    if (item && !item.contains(event.relatedTarget)) {
      item.classList.remove('scale-105', 'border-blue-500')
      // Restore original border if no feedback color
      if (!item.classList.contains('border-green-500') && !item.classList.contains('border-red-500')) {
        item.classList.add('border-cyan-400')
      }
    }
  }

  handleDrop(event) {
    event.preventDefault()

    const dropTarget = event.target.closest('[data-sortable-target="item"]')
    if (!dropTarget || dropTarget === this.draggedElement) return

    dropTarget.classList.remove('scale-105', 'border-blue-500')
    // Restore original border
    if (!dropTarget.classList.contains('border-green-500') && !dropTarget.classList.contains('border-red-500')) {
      dropTarget.classList.add('border-cyan-400')
    }

    // Get position of drop target
    const container = this.containerTarget
    const items = [...container.children]
    const draggedIndex = items.indexOf(this.draggedElement)
    const dropIndex = items.indexOf(dropTarget)

    // Swap or insert
    if (draggedIndex < dropIndex) {
      container.insertBefore(this.draggedElement, dropTarget.nextSibling)
    } else {
      container.insertBefore(this.draggedElement, dropTarget)
    }

    this.updateHiddenInputs()
  }

  // Touch support for mobile devices
  handleTouchStart(event) {
    const item = event.target.closest('[data-sortable-target="item"]')
    if (!item) return

    // Clear all feedback colors when starting a new drag
    this.itemTargets.forEach(i => {
      i.classList.remove('border-green-500', 'border-red-500', 'bg-green-50', 'bg-red-50')
      i.classList.add('border-cyan-400', 'bg-transparent')
    })

    this.touchedElement = item
    this.touchStartY = event.touches[0].clientY
    this.touchStartX = event.touches[0].clientX

    // Create clone for drag preview
    this.touchClone = item.cloneNode(true)
    this.touchClone.style.position = 'fixed'
    this.touchClone.style.zIndex = '1000'
    this.touchClone.style.pointerEvents = 'none'
    this.touchClone.style.opacity = '0.8'
    this.touchClone.style.transform = 'scale(1.05)'
    document.body.appendChild(this.touchClone)

    item.classList.add('opacity-50')

    this.updateTouchClonePosition(event.touches[0])
  }

  handleTouchMove(event) {
    if (!this.touchedElement) return
    event.preventDefault()

    this.updateTouchClonePosition(event.touches[0])

    // Find element under touch point
    this.touchClone.style.display = 'none'
    const elementBelow = document.elementFromPoint(
      event.touches[0].clientX,
      event.touches[0].clientY
    )
    this.touchClone.style.display = ''

    const dropTarget = elementBelow?.closest('[data-sortable-target="item"]')

    // Clear previous highlight
    this.itemTargets.forEach(i => {
      i.classList.remove('scale-105', 'border-blue-500')
      // Restore original border if no feedback color
      if (!i.classList.contains('border-green-500') && !i.classList.contains('border-red-500')) {
        i.classList.add('border-cyan-400')
      }
    })

    // Highlight drop target
    if (dropTarget && dropTarget !== this.touchedElement) {
      dropTarget.classList.remove('border-cyan-400')
      dropTarget.classList.add('scale-105', 'border-blue-500')
      this.currentDropTarget = dropTarget
    } else {
      this.currentDropTarget = null
    }
  }

  handleTouchEnd(event) {
    if (!this.touchedElement) return

    // Remove clone
    if (this.touchClone) {
      this.touchClone.remove()
      this.touchClone = null
    }

    this.touchedElement.classList.remove('opacity-50')

    // Perform drop
    if (this.currentDropTarget && this.currentDropTarget !== this.touchedElement) {
      const container = this.containerTarget
      const items = [...container.children]
      const draggedIndex = items.indexOf(this.touchedElement)
      const dropIndex = items.indexOf(this.currentDropTarget)

      if (draggedIndex < dropIndex) {
        container.insertBefore(this.touchedElement, this.currentDropTarget.nextSibling)
      } else {
        container.insertBefore(this.touchedElement, this.currentDropTarget)
      }
    }

    // Clear highlights and restore original borders
    this.itemTargets.forEach(i => {
      i.classList.remove('scale-105', 'border-blue-500')
      // Restore original border if no feedback color
      if (!i.classList.contains('border-green-500') && !i.classList.contains('border-red-500')) {
        i.classList.add('border-cyan-400')
      }
    })

    this.touchedElement = null
    this.currentDropTarget = null
    this.updateHiddenInputs()
  }

  updateTouchClonePosition(touch) {
    if (!this.touchClone) return

    const rect = this.touchedElement.getBoundingClientRect()
    this.touchClone.style.left = `${touch.clientX - rect.width / 2}px`
    this.touchClone.style.top = `${touch.clientY - rect.height / 2}px`
    this.touchClone.style.width = `${rect.width}px`
  }

  // Reset to shuffled state
  reset() {
    // Remove all feedback styling and restore original
    this.itemTargets.forEach(item => {
      item.classList.remove('opacity-50', 'scale-105', 'border-blue-500', 'bg-blue-50',
                           'border-green-500', 'border-red-500', 'bg-green-50', 'bg-red-50')
      // Restore original styling
      item.classList.add('border-2', 'border-cyan-400', 'bg-transparent')
    })

    // Reshuffle
    this.shuffleItems()
  }

  // Called by exercise-checker to verify answers
  checkAnswers() {
    const correctOrder = this.getCorrectOrder()

    let correctCount = 0
    let incorrectCount = 0

    // Check each position and highlight
    this.itemTargets.forEach((item, index) => {
      const currentValue = this.getIdentifier(item)
      const isCorrect = currentValue === correctOrder[index]

      // Remove previous feedback styling but keep border-2
      item.classList.remove('border-green-500', 'border-red-500', 'bg-green-50', 'bg-red-50',
                           'border-cyan-400', 'border-blue-500', 'bg-blue-50', 'bg-transparent')

      if (isCorrect) {
        correctCount++
        item.classList.add('border-green-500', 'bg-green-50')
      } else {
        incorrectCount++
        item.classList.add('border-red-500', 'bg-red-50')
        // Shake animation
        item.classList.add('animate-shake')
        setTimeout(() => item.classList.remove('animate-shake'), 500)
      }
    })

    return {
      allCorrect: incorrectCount === 0,
      correctCount,
      incorrectCount,
      total: this.itemTargets.length
    }
  }

  // Called by exercise-checker to show correct solution
  showSolution() {
    const correctOrder = this.getCorrectOrder()
    const container = this.containerTarget

    // Sort items according to correct order
    const sortedItems = [...this.itemTargets].sort((a, b) => {
      const aIndex = correctOrder.indexOf(this.getIdentifier(a))
      const bIndex = correctOrder.indexOf(this.getIdentifier(b))
      return aIndex - bIndex
    })

    // Re-append in correct order
    sortedItems.forEach(item => {
      container.appendChild(item)
      // Style as correct - remove other borders, add green
      item.classList.remove('border-cyan-400', 'border-red-500', 'bg-red-50', 'border-blue-500', 'bg-blue-50', 'bg-transparent')
      item.classList.add('border-green-500', 'bg-green-50')
    })

    this.updateHiddenInputs()
  }

  // Restore original styling (called externally if needed)
  restoreOriginalStyle() {
    this.itemTargets.forEach(item => {
      item.classList.remove('border-green-500', 'border-red-500', 'bg-green-50', 'bg-red-50',
                           'border-blue-500', 'bg-blue-50')
      item.classList.add('border-cyan-400', 'bg-transparent')
    })
  }
}
