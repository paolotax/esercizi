import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar-nav"
export default class extends Controller {
  static targets = ["item", "children"]

  connect() {
    // Ripristina lo stato salvato in localStorage
    this.restoreState()
    // Evidenzia la pagina corrente e apre i livelli necessari
    // Usa un piccolo delay per assicurarsi che il DOM sia pronto
    setTimeout(() => {
      this.highlightCurrentPage()
    }, 0)

    // Listener per aggiornare l'evidenziazione e lo stato dopo ogni navigazione Turbo
    this.turboLoadHandler = () => {
      // Piccolo delay per assicurarsi che il DOM sia aggiornato
      setTimeout(() => {
        this.restoreState()
        this.highlightCurrentPage()
      }, 0)
    }
    
    this.turboFrameLoadHandler = () => {
      setTimeout(() => {
        this.restoreState()
        this.highlightCurrentPage()
      }, 0)
    }

    // Listener per turbo:before-visit per salvare lo stato prima della navigazione
    this.turboBeforeVisitHandler = () => {
      // Salva lo stato corrente prima della navigazione
      this.saveCurrentState()
    }

    document.addEventListener('turbo:load', this.turboLoadHandler)
    document.addEventListener('turbo:frame-load', this.turboFrameLoadHandler)
    document.addEventListener('turbo:before-visit', this.turboBeforeVisitHandler)
    
    // Listener anche per turbo:render per gestire elementi permanenti aggiornati
    document.addEventListener('turbo:render', this.turboLoadHandler)
  }

  disconnect() {
    // Rimuove i listener quando il controller viene disconnesso
    if (this.turboLoadHandler) {
      document.removeEventListener('turbo:load', this.turboLoadHandler)
      document.removeEventListener('turbo:render', this.turboLoadHandler)
    }
    if (this.turboFrameLoadHandler) {
      document.removeEventListener('turbo:frame-load', this.turboFrameLoadHandler)
    }
    if (this.turboBeforeVisitHandler) {
      document.removeEventListener('turbo:before-visit', this.turboBeforeVisitHandler)
    }
  }

  saveCurrentState() {
    // Salva lo stato corrente degli elementi aperti
    // Questo metodo viene chiamato prima della navigazione per preservare lo stato
    const openItems = []
    const buttons = this.element.querySelectorAll('button[data-sidebar-item-id]')
    
    buttons.forEach(button => {
      const itemId = button.getAttribute('data-sidebar-item-id')
      if (itemId) {
        let childrenContainer = button.nextElementSibling
        
        if (!childrenContainer || !childrenContainer.classList.contains('sidebar-children')) {
          childrenContainer = this.element.querySelector(`[data-sidebar-children-id="${itemId}"]`)
        }
        
        if (childrenContainer && childrenContainer.classList.contains('open')) {
          openItems.push(itemId)
        }
      }
    })
    
    localStorage.setItem('sidebar-open-items', JSON.stringify(openItems))
  }

  toggle(event) {
    event.preventDefault()
    const item = event.currentTarget
    const itemId = item.getAttribute('data-sidebar-item-id')
    
    if (!itemId) return

    // Cerca il contenitore children associato (può essere nextElementSibling o trovato tramite data attribute)
    let childrenContainer = item.nextElementSibling
    
    // Se non è il next sibling, cerca tramite data attribute
    if (!childrenContainer || !childrenContainer.classList.contains('sidebar-children')) {
      childrenContainer = this.element.querySelector(`[data-sidebar-children-id="${itemId}"]`)
    }

    if (childrenContainer && childrenContainer.classList.contains('sidebar-children')) {
      const isOpen = childrenContainer.classList.contains('open')

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

  getItemId(item) {
    // Usa l'attributo data-sidebar-item-id se presente, altrimenti fallback al metodo precedente
    return item.getAttribute('data-sidebar-item-id') || this.generateItemId(item)
  }

  generateItemId(item) {
    // Fallback: genera un ID univoco basato sul testo del bottone
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
    
    if (openItems.length === 0) return

    // Per ogni item salvato come aperto, trova il bottone e apri il suo contenuto
    openItems.forEach(itemId => {
      const button = this.element.querySelector(`[data-sidebar-item-id="${itemId}"]`)
      
      if (button) {
        let childrenContainer = button.nextElementSibling
        
        // Se non è il next sibling, cerca tramite data attribute
        if (!childrenContainer || !childrenContainer.classList.contains('sidebar-children')) {
          childrenContainer = this.element.querySelector(`[data-sidebar-children-id="${itemId}"]`)
        }

        if (childrenContainer && childrenContainer.classList.contains('sidebar-children')) {
          childrenContainer.classList.add('open')
          button.querySelector('.toggle-icon')?.classList.add('rotate-90')
        }
      }
    })
  }

  highlightCurrentPage() {
    const currentPath = window.location.pathname
    
    // Se siamo sulla home, non evidenziare nulla
    if (currentPath === '/' || currentPath === '') {
      const links = this.element.querySelectorAll('a')
      links.forEach(link => {
        link.classList.remove('bg-blue-100', 'border-l-4', 'border-blue-500')
      })
      return
    }
    
    // Normalizza il path (rimuove trailing slash se presente, tranne root)
    const normalizedPath = currentPath === '/' ? '/' : currentPath.replace(/\/$/, '')
    
    const links = this.element.querySelectorAll('a')

    // Prima rimuovi tutti gli highlight
    links.forEach(link => {
      link.classList.remove('bg-blue-100', 'border-l-4', 'border-blue-500')
    })

    // Poi evidenzia il link corrente (escludendo il link home)
    links.forEach(link => {
      const linkHref = link.getAttribute('href')
      
      // Salta il link home (root path)
      if (linkHref === '/' || linkHref === '') {
        return
      }
      
      // Normalizza anche l'href del link
      const normalizedHref = linkHref === '/' ? '/' : linkHref.replace(/\/$/, '')
      
      // Confronta i path normalizzati
      if (normalizedHref === normalizedPath) {
        link.classList.add('bg-blue-100', 'border-l-4', 'border-blue-500')

        // Apri tutti i livelli superiori per mostrare la pagina corrente
        let parent = link.parentElement
        while (parent && parent !== this.element) {
          if (parent.classList.contains('sidebar-children')) {
            parent.classList.add('open')
            const button = parent.previousElementSibling
            
            if (button && button.tagName === 'BUTTON') {
              button.querySelector('.toggle-icon')?.classList.add('rotate-90')
              const itemId = this.getItemId(button)
              if (itemId) {
                this.saveOpenState(itemId)
              }
            }
          }
          parent = parent.parentElement
        }
      }
    })
  }
}
