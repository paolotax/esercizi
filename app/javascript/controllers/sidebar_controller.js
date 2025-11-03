import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar"
export default class extends Controller {
  static targets = ["sidebar"]

  connect() {
    // Controlla se siamo nella home (root route)
    const isHome = this.isHomePage()
    
    if (isHome) {
      // Nella home, nascondi sempre la sidebar
      if (this.hasSidebarTarget) {
        this.sidebarTarget.classList.add("hidden")
        this.saveSidebarVisibility(false)
      }
    } else {
      // Altrimenti, ripristina lo stato salvato
      this.restoreSidebarVisibility()
    }

    // Listener per aggiornare lo stato dopo ogni navigazione Turbo
    this.turboLoadHandler = () => {
      const isHomeNow = this.isHomePage()
      
      if (isHomeNow) {
        // Nella home, nascondi sempre
        if (this.hasSidebarTarget) {
          this.sidebarTarget.classList.add("hidden")
          this.saveSidebarVisibility(false)
        }
      } else {
        // Altrimenti, ripristina lo stato
        this.restoreSidebarVisibility()
      }
    }

    document.addEventListener('turbo:load', this.turboLoadHandler)
    document.addEventListener('turbo:frame-load', this.turboLoadHandler)
  }

  disconnect() {
    // Rimuove i listener quando il controller viene disconnesso
    if (this.turboLoadHandler) {
      document.removeEventListener('turbo:load', this.turboLoadHandler)
      document.removeEventListener('turbo:frame-load', this.turboLoadHandler)
    }
  }

  isHomePage() {
    // La home è la root route (/)
    const path = window.location.pathname
    return path === '/' || path === ''
  }

  saveSidebarVisibility(isVisible) {
    localStorage.setItem('sidebar-visible', JSON.stringify(isVisible))
  }

  getSidebarVisibility() {
    const stored = localStorage.getItem('sidebar-visible')
    // Default: visibile (true) tranne che nella home
    return stored ? JSON.parse(stored) : true
  }

  restoreSidebarVisibility() {
    if (!this.hasSidebarTarget) return
    
    const isVisible = this.getSidebarVisibility()
    
    if (isVisible) {
      this.sidebarTarget.classList.remove("hidden")
    } else {
      this.sidebarTarget.classList.add("hidden")
    }
  }

  toggle(event) {
    if (event) event.preventDefault()

    if (this.hasSidebarTarget) {
      const isHidden = this.sidebarTarget.classList.contains("hidden")
      
      if (isHidden) {
        this.sidebarTarget.classList.remove("hidden")
        this.saveSidebarVisibility(true)
      } else {
        this.sidebarTarget.classList.add("hidden")
        this.saveSidebarVisibility(false)
      }
    } else {
      console.error("Sidebar target not found")
    }
  }

  close(event) {
    if (event) event.preventDefault()

    if (this.hasSidebarTarget) {
      this.sidebarTarget.classList.add("hidden")
      this.saveSidebarVisibility(false)
    } else {
      console.error("Sidebar target not found")
    }
  }
}
