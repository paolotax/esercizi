import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar-nav"
export default class extends Controller {
  static targets = ["item", "children"]

  connect() {
    // Ripristina lo stato salvato in localStorage
    this.restoreState()
    // Evidenzia la pagina corrente
    this.highlightCurrentPage()

    // Listener per aggiornare l'evidenziazione dopo ogni navigazione Turbo
    document.addEventListener('turbo:load', () => {
      this.highlightCurrentPage()
    })
  }

  toggle(event) {
    event.preventDefault()
    const item = event.currentTarget
    const childrenContainer = item.nextElementSibling

    if (childrenContainer && childrenContainer.classList.contains('sidebar-children')) {
      const isOpen = childrenContainer.classList.contains('open')
      const itemId = this.generateItemId(item)

      if (isOpen) {
        // Chiudi
        childrenContainer.classList.remove('open')
        item.querySelector('.toggle-icon')?.classList.remove('rotate-90')
        this.saveClosedState(itemId)
      } else {
        // Apri
        childrenContainer.classList.add('open')
        item.querySelector('.toggle-icon')?.classList.add('rotate-90')
        this.saveOpenState(itemId)
      }
    }
  }

  generateItemId(item) {
    // Genera un ID univoco basato sul testo del bottone
    const text = item.querySelector('.font-semibold, .font-medium')?.textContent.trim()
    return text ? text.replace(/\s+/g, '-').toLowerCase() : ''
  }

  saveOpenState(itemId) {
    if (!itemId) return
    const openItems = this.getOpenItems()
    if (!openItems.includes(itemId)) {
      openItems.push(itemId)
      localStorage.setItem('sidebar-open-items', JSON.stringify(openItems))
    }
  }

  saveClosedState(itemId) {
    if (!itemId) return
    const openItems = this.getOpenItems()
    const index = openItems.indexOf(itemId)
    if (index > -1) {
      openItems.splice(index, 1)
      localStorage.setItem('sidebar-open-items', JSON.stringify(openItems))
    }
  }

  getOpenItems() {
    const stored = localStorage.getItem('sidebar-open-items')
    return stored ? JSON.parse(stored) : []
  }

  restoreState() {
    const openItems = this.getOpenItems()

    // Per ogni item salvato come aperto, trova il bottone e apri il suo contenuto
    openItems.forEach(itemId => {
      const buttons = this.element.querySelectorAll('button')
      buttons.forEach(button => {
        const currentId = this.generateItemId(button)
        if (currentId === itemId) {
          const childrenContainer = button.nextElementSibling
          if (childrenContainer && childrenContainer.classList.contains('sidebar-children')) {
            childrenContainer.classList.add('open')
            button.querySelector('.toggle-icon')?.classList.add('rotate-90')
          }
        }
      })
    })
  }

  highlightCurrentPage() {
    const currentPath = window.location.pathname
    const links = this.element.querySelectorAll('a')

    links.forEach(link => {
      if (link.getAttribute('href') === currentPath) {
        link.classList.add('bg-blue-100', 'border-l-4', 'border-blue-500')

        // Apri tutti i livelli superiori per mostrare la pagina corrente
        let parent = link.parentElement
        while (parent && parent !== this.element) {
          if (parent.classList.contains('sidebar-children')) {
            parent.classList.add('open')
            const button = parent.previousElementSibling
            if (button && button.tagName === 'BUTTON') {
              button.querySelector('.toggle-icon')?.classList.add('rotate-90')
              const itemId = this.generateItemId(button)
              this.saveOpenState(itemId)
            }
          }
          parent = parent.parentElement
        }
      } else {
        link.classList.remove('bg-blue-100', 'border-l-4', 'border-blue-500')
      }
    })
  }
}
