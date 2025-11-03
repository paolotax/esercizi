import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar"
export default class extends Controller {
  static targets = ["sidebar", "overlay"]

  connect() {
    // Controlla se siamo nella home (root route)
    const isHome = this.isHomePage()
    
    // Su mobile, nascondi sempre di default
    if (this.isMobile()) {
      if (this.hasSidebarTarget) {
        this.sidebarTarget.classList.add("hidden")
      }
      if (this.hasOverlayTarget) {
        this.overlayTarget.classList.add("hidden")
      }
    } else if (isHome) {
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
      // Su mobile, nascondi sempre
      if (this.isMobile()) {
        if (this.hasSidebarTarget) {
          this.sidebarTarget.classList.add("hidden")
        }
        if (this.hasOverlayTarget) {
          this.overlayTarget.classList.add("hidden")
        }
        document.body.style.overflow = ''
        return
      }
      
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

  isMobile() {
    // Controlla se siamo su mobile (schermo < 768px)
    return window.innerWidth < 768
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
    
    // Su mobile, non ripristinare lo stato salvato (sempre nascosta)
    if (this.isMobile()) {
      this.sidebarTarget.classList.add("hidden")
      if (this.hasOverlayTarget) {
        this.overlayTarget.classList.add("hidden")
      }
      return
    }
    
    const isVisible = this.getSidebarVisibility()
    
    if (isVisible) {
      this.sidebarTarget.classList.remove("hidden")
    } else {
      this.sidebarTarget.classList.add("hidden")
    }
  }

  toggle(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }

    if (!this.hasSidebarTarget) {
      console.error("Sidebar target not found")
      return
    }

    const isMobile = this.isMobile()
    const isHidden = this.sidebarTarget.classList.contains("hidden")
    
    if (isHidden) {
      // Mostra sidebar
      this.sidebarTarget.classList.remove("hidden")
      
      // Su mobile, mostra anche l'overlay
      if (isMobile && this.hasOverlayTarget) {
        this.overlayTarget.classList.remove("hidden")
        // Previeni lo scroll del body
        document.body.style.overflow = 'hidden'
      }
      
      // Salva lo stato solo su desktop
      if (!isMobile) {
        this.saveSidebarVisibility(true)
      }
    } else {
      // Nascondi sidebar
      this.sidebarTarget.classList.add("hidden")
      
      // Su mobile, nascondi anche l'overlay
      if (isMobile && this.hasOverlayTarget) {
        this.overlayTarget.classList.add("hidden")
        // Ripristina lo scroll del body
        document.body.style.overflow = ''
      }
      
      // Salva lo stato solo su desktop
      if (!isMobile) {
        this.saveSidebarVisibility(false)
      }
    }
  }

  close(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }

    if (this.hasSidebarTarget) {
      this.sidebarTarget.classList.add("hidden")
      
      // Su mobile, nascondi anche l'overlay
      if (this.isMobile() && this.hasOverlayTarget) {
        this.overlayTarget.classList.add("hidden")
        document.body.style.overflow = ''
      }
      
      // Salva lo stato solo su desktop
      if (!this.isMobile()) {
        this.saveSidebarVisibility(false)
      }
    } else {
      console.error("Sidebar target not found")
    }
  }
}
