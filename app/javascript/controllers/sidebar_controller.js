import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar"
export default class extends Controller {
  static targets = ["sidebar", "overlay"]

  connect() {
    // Evita di re-inizializzare se già configurato (turbo-permanent)
    if (this.element.dataset.sidebarInitialized) {
      return
    }
    this.element.dataset.sidebarInitialized = "true"

    // Su mobile, nascondi sempre di default
    if (this.isMobile()) {
      if (this.hasSidebarTarget) {
        this.sidebarTarget.classList.add("hidden")
      }
      if (this.hasOverlayTarget) {
        this.overlayTarget.classList.add("hidden")
      }
    } else {
      // Su desktop, ripristina lo stato salvato
      this.restoreSidebarVisibility()
    }

    // Aggiungi listener per resize
    this.boundHandleResize = this.handleResize.bind(this)
    window.addEventListener('resize', this.boundHandleResize)
  }

  disconnect() {
    // Rimuovi listener per resize
    if (this.boundHandleResize) {
      window.removeEventListener('resize', this.boundHandleResize)
    }
  }

  handleResize() {
    const isMobile = this.isMobile()
    const isSidebarVisible = this.hasSidebarTarget && !this.sidebarTarget.classList.contains("hidden")

    if (isMobile && isSidebarVisible) {
      // Passaggio a mobile con sidebar visibile: mostra overlay
      if (this.hasOverlayTarget) {
        this.overlayTarget.classList.remove("hidden")
        document.body.style.overflow = 'hidden'
      }
    } else if (!isMobile) {
      // Passaggio a desktop: nascondi overlay
      if (this.hasOverlayTarget) {
        this.overlayTarget.classList.add("hidden")
        document.body.style.overflow = ''
      }
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
