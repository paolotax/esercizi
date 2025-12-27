import { Controller } from "@hotwired/stimulus"

// Controller for reordering questions in the exercise builder
export default class extends Controller {
  static values = {
    url: String
  }

  connect() {
    this.setupDragAndDrop()
  }

  setupDragAndDrop() {
    const items = this.element.querySelectorAll('[data-sortable-id]')

    items.forEach(item => {
      const handle = item.querySelector('[data-sortable-handle]')
      if (handle) {
        handle.addEventListener('mousedown', () => {
          item.draggable = true
        })
        handle.addEventListener('mouseup', () => {
          item.draggable = false
        })
      }

      item.addEventListener('dragstart', (e) => this.handleDragStart(e))
      item.addEventListener('dragend', (e) => this.handleDragEnd(e))
      item.addEventListener('dragover', (e) => this.handleDragOver(e))
      item.addEventListener('drop', (e) => this.handleDrop(e))
    })
  }

  handleDragStart(event) {
    this.draggedElement = event.target.closest('[data-sortable-id]')
    this.draggedElement.classList.add('opacity-50')
    event.dataTransfer.effectAllowed = 'move'
    event.dataTransfer.setData('text/plain', this.draggedElement.dataset.sortableId)
  }

  handleDragEnd(event) {
    const item = event.target.closest('[data-sortable-id]')
    if (item) {
      item.classList.remove('opacity-50')
      item.draggable = false
    }
    this.draggedElement = null
  }

  handleDragOver(event) {
    event.preventDefault()
    const target = event.target.closest('[data-sortable-id]')
    if (target && target !== this.draggedElement) {
      const rect = target.getBoundingClientRect()
      const midY = rect.top + rect.height / 2

      if (event.clientY < midY) {
        target.parentNode.insertBefore(this.draggedElement, target)
      } else {
        target.parentNode.insertBefore(this.draggedElement, target.nextSibling)
      }
    }
  }

  handleDrop(event) {
    event.preventDefault()
    this.saveOrder()
  }

  async saveOrder() {
    const items = this.element.querySelectorAll('[data-sortable-id]')
    const ids = Array.from(items).map(item => item.dataset.sortableId)

    // Aggiorna i numeri delle posizioni visualizzate
    this.updatePositionNumbers()

    try {
      const response = await fetch(this.urlValue, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ question_ids: ids })
      })

      if (!response.ok) {
        console.error('Failed to save order')
      }
    } catch (error) {
      console.error('Error saving order:', error)
    }
  }

  updatePositionNumbers() {
    const items = this.element.querySelectorAll('[data-sortable-id]')
    items.forEach((item, index) => {
      const handle = item.querySelector('[data-sortable-handle]')
      if (handle) {
        handle.textContent = index + 1
      }
    })
  }
}
