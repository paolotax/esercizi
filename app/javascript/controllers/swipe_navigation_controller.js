import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Gestisce la navigazione tra pagine tramite swipe su dispositivi touch
export default class extends Controller {
  static values = {
    prevUrl: String,
    nextUrl: String,
    threshold: { type: Number, default: 80 },
    resistance: { type: Number, default: 0.4 }
  }

  connect() {
    this.startX = 0
    this.startY = 0
    this.currentX = 0
    this.isHorizontalSwipe = null
    this.isSwiping = false

    // Reset stili (per quando si arriva via Turbo da uno swipe)
    this.element.style.transform = ''
    this.element.style.opacity = ''
    this.element.style.transition = ''

    // Bind touch events
    this.handleTouchStart = this.handleTouchStart.bind(this)
    this.handleTouchMove = this.handleTouchMove.bind(this)
    this.handleTouchEnd = this.handleTouchEnd.bind(this)

    this.element.addEventListener('touchstart', this.handleTouchStart, { passive: true })
    this.element.addEventListener('touchmove', this.handleTouchMove, { passive: false })
    this.element.addEventListener('touchend', this.handleTouchEnd, { passive: true })
  }

  disconnect() {
    this.element.removeEventListener('touchstart', this.handleTouchStart)
    this.element.removeEventListener('touchmove', this.handleTouchMove)
    this.element.removeEventListener('touchend', this.handleTouchEnd)
  }

  handleTouchStart(e) {
    // Ignora se il touch parte da un elemento interattivo
    const target = e.target
    if (this.isInteractiveElement(target)) {
      this.isSwiping = false
      return
    }

    this.startX = e.touches[0].clientX
    this.startY = e.touches[0].clientY
    this.currentX = 0
    this.isHorizontalSwipe = null
    this.isSwiping = true

    // Rimuovi transizione durante il drag
    this.element.style.transition = 'none'
  }

  handleTouchMove(e) {
    if (!this.isSwiping) return

    const touchX = e.touches[0].clientX
    const touchY = e.touches[0].clientY
    const deltaX = touchX - this.startX
    const deltaY = touchY - this.startY

    // Determina direzione swipe al primo movimento significativo
    if (this.isHorizontalSwipe === null && (Math.abs(deltaX) > 10 || Math.abs(deltaY) > 10)) {
      this.isHorizontalSwipe = Math.abs(deltaX) > Math.abs(deltaY)
    }

    // Se è uno swipe verticale, lascia fare lo scroll normale
    if (this.isHorizontalSwipe === false) {
      this.isSwiping = false
      return
    }

    // Se è uno swipe orizzontale
    if (this.isHorizontalSwipe === true) {
      // Blocca swipe se non c'è pagina in quella direzione
      if (deltaX > 0 && !this.hasPrevUrlValue) return
      if (deltaX < 0 && !this.hasNextUrlValue) return

      // Previeni scroll e applica trasformazione
      e.preventDefault()

      // Applica resistenza per effetto elastico
      this.currentX = deltaX * this.resistanceValue
      this.element.style.transform = `translateX(${this.currentX}px)`
    }
  }

  handleTouchEnd() {
    if (!this.isSwiping || this.isHorizontalSwipe !== true) {
      this.resetPosition()
      return
    }

    const deltaX = this.currentX / this.resistanceValue // Delta originale

    // Aggiungi transizione per animazione finale
    this.element.style.transition = 'transform 0.3s ease-out'

    if (deltaX > this.thresholdValue && this.hasPrevUrlValue) {
      // Swipe a destra -> pagina precedente
      this.animateAndNavigate('right', this.prevUrlValue)
    } else if (deltaX < -this.thresholdValue && this.hasNextUrlValue) {
      // Swipe a sinistra -> pagina successiva
      this.animateAndNavigate('left', this.nextUrlValue)
    } else {
      // Swipe non sufficiente, torna indietro
      this.resetPosition()
    }
  }

  animateAndNavigate(direction, url) {
    const offset = direction === 'left' ? -window.innerWidth : window.innerWidth
    this.element.style.transform = `translateX(${offset}px)`
    this.element.style.opacity = '0'

    // Usa Turbo per navigazione fluida (evita flash bianco)
    setTimeout(() => {
      Turbo.visit(url)
    }, 150)
  }

  resetPosition() {
    this.element.style.transition = 'transform 0.3s ease-out'
    this.element.style.transform = 'translateX(0)'

    // Pulisci dopo la transizione
    setTimeout(() => {
      this.element.style.transition = ''
      this.element.style.transform = ''
    }, 300)
  }

  isInteractiveElement(element) {
    // Controlla se l'elemento o un suo parent è interattivo
    const interactiveTags = ['INPUT', 'TEXTAREA', 'SELECT', 'BUTTON', 'A']
    const interactiveSelectors = [
      '[data-controller*="sortable"]',
      '[data-controller*="drag"]',
      '[draggable="true"]',
      '.sortable-item'
    ]

    let current = element
    while (current && current !== this.element) {
      if (interactiveTags.includes(current.tagName)) return true
      if (interactiveSelectors.some(sel => current.matches?.(sel))) return true
      current = current.parentElement
    }

    return false
  }
}
