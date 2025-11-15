import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "hotspot", "info"]

  connect() {
    console.log("Hotspot editor connected")
    this.dragging = null
    this.startX = 0
    this.startY = 0
    this.startLeft = 0
    this.startTop = 0

    // Aggiungi info panel se non esiste
    this.createInfoPanel()
  }

  createInfoPanel() {
    if (!this.hasInfoTarget) {
      const info = document.createElement('div')
      info.dataset.hotspotEditorTarget = "info"
      info.className = "fixed top-4 right-4 bg-white border-4 border-blue-500 rounded-lg p-4 shadow-2xl z-50 max-w-md"
      info.innerHTML = `
        <h3 class="font-bold text-lg mb-2 text-blue-700">Hotspot Editor</h3>
        <div class="text-xs space-y-1">
          <p class="text-gray-600">Trascina gli hotspot per posizionarli</p>
          <div id="hotspot-values" class="mt-3 font-mono text-xs bg-gray-100 p-2 rounded max-h-96 overflow-y-auto"></div>
        </div>
      `
      document.body.appendChild(info)
    }
  }

  startDrag(event) {
    event.preventDefault()

    this.dragging = event.currentTarget
    const rect = this.dragging.getBoundingClientRect()
    const containerRect = this.containerTarget.getBoundingClientRect()

    this.startX = event.clientX
    this.startY = event.clientY

    // Posizione corrente in percentuale
    const currentLeft = parseFloat(this.dragging.style.left)
    const currentTop = parseFloat(this.dragging.style.top)

    this.startLeft = currentLeft
    this.startTop = currentTop

    // Aggiungi classe visual feedback
    this.dragging.classList.add('ring-4', 'ring-yellow-400', 'z-50')

    // Bind events
    this.boundMouseMove = this.drag.bind(this)
    this.boundMouseUp = this.stopDrag.bind(this)

    document.addEventListener('mousemove', this.boundMouseMove)
    document.addEventListener('mouseup', this.boundMouseUp)
  }

  drag(event) {
    if (!this.dragging) return

    event.preventDefault()

    const containerRect = this.containerTarget.getBoundingClientRect()
    const deltaX = event.clientX - this.startX
    const deltaY = event.clientY - this.startY

    // Calcola percentuali
    const deltaXPercent = (deltaX / containerRect.width) * 100
    const deltaYPercent = (deltaY / containerRect.height) * 100

    let newLeft = this.startLeft + deltaXPercent
    let newTop = this.startTop + deltaYPercent

    // Limita ai bordi del contenitore
    const width = parseFloat(this.dragging.style.width)
    const height = parseFloat(this.dragging.style.height)

    newLeft = Math.max(0, Math.min(newLeft, 100 - width))
    newTop = Math.max(0, Math.min(newTop, 100 - height))

    // Applica nuova posizione
    this.dragging.style.left = `${newLeft}%`
    this.dragging.style.top = `${newTop}%`

    // Aggiorna info panel in tempo reale
    this.updateInfoPanel()
  }

  stopDrag(event) {
    if (!this.dragging) return

    // Rimuovi visual feedback
    this.dragging.classList.remove('ring-4', 'ring-yellow-400', 'z-50')

    // Aggiorna info finale
    this.updateInfoPanel()

    // Log in console
    const label = this.dragging.querySelector('.sr-only')?.textContent || 'Unknown'
    console.log(`{ label: "${label}", top: "${this.dragging.style.top}", left: "${this.dragging.style.left}", width: "${this.dragging.style.width}", height: "${this.dragging.style.height}" },`)

    // Cleanup
    document.removeEventListener('mousemove', this.boundMouseMove)
    document.removeEventListener('mouseup', this.boundMouseUp)

    this.dragging = null
  }

  updateInfoPanel() {
    const valuesDiv = document.getElementById('hotspot-values')
    if (!valuesDiv) return

    const hotspots = this.hotspotTargets.map(hotspot => {
      const label = hotspot.querySelector('.sr-only')?.textContent || 'Unknown'
      return {
        label,
        top: hotspot.style.top,
        left: hotspot.style.left,
        width: hotspot.style.width,
        height: hotspot.style.height
      }
    })

    valuesDiv.innerHTML = hotspots.map(h =>
      `<div class="mb-2 p-2 border border-gray-300 rounded ${this.dragging?.querySelector('.sr-only')?.textContent === h.label ? 'bg-yellow-200 font-bold' : ''}">
        <div class="font-bold text-blue-700">${h.label}</div>
        <div>top: "${h.top}", left: "${h.left}"</div>
        <div>width: "${h.width}", height: "${h.height}"</div>
        <div class="text-xs text-gray-500 mt-1">
          { label: "${h.label}", top: "${h.top}", left: "${h.left}", width: "${h.width}", height: "${h.height}" }
        </div>
      </div>`
    ).join('')
  }

  copyAll() {
    const hotspots = this.hotspotTargets.map(hotspot => {
      const label = hotspot.querySelector('.sr-only')?.textContent || 'Unknown'
      return `        { label: "${label}", top: "${hotspot.style.top}", left: "${hotspot.style.left}", width: "${hotspot.style.width}", height: "${hotspot.style.height}" }`
    }).join(',\n')

    const code = `      <% hotspots = [\n${hotspots}\n      ] %>`

    navigator.clipboard.writeText(code).then(() => {
      alert('Codice copiato negli appunti!')
      console.log(code)
    })
  }

  disconnect() {
    // Cleanup info panel
    if (this.hasInfoTarget) {
      this.infoTarget.remove()
    }
  }
}
