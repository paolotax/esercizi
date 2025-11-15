import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "hotspot", "info"]

  connect() {
    console.log("Hotspot editor connected")
    this.dragging = null
    this.resizing = null
    this.startX = 0
    this.startY = 0
    this.startLeft = 0
    this.startTop = 0
    this.startWidth = 0
    this.startHeight = 0

    // Aggiungi info panel se non esiste
    this.createInfoPanel()

    // Aggiungi resize handles a tutti gli hotspot
    this.addResizeHandles()
  }

  addResizeHandles() {
    this.hotspotTargets.forEach(hotspot => {
      if (!hotspot.querySelector('[data-resize-handle]')) {
        const handle = document.createElement('div')
        handle.dataset.resizeHandle = ''
        handle.className = 'absolute bottom-0 right-0 w-3 h-3 bg-white border-2 border-current rounded-full cursor-nwse-resize'
        handle.addEventListener('mousedown', (e) => this.startResize(e, hotspot))
        hotspot.appendChild(handle)
      }
    })
  }

  createInfoPanel() {
    if (!this.hasInfoTarget) {
      const info = document.createElement('div')
      info.dataset.hotspotEditorTarget = "info"
      info.className = "fixed top-4 right-4 bg-white border-4 border-blue-500 rounded-lg shadow-2xl z-50 cursor-move"
      info.style.width = "600px"
      info.innerHTML = `
        <div class="bg-blue-500 text-white px-3 py-2 font-bold text-sm" data-panel-header>
          Hotspot Values (drag to move)
        </div>
        <div id="hotspot-values" class="font-mono text-xs bg-gray-100 p-3 max-h-96 overflow-y-auto"></div>
      `
      document.body.appendChild(info)

      // Make panel draggable
      const header = info.querySelector('[data-panel-header]')
      let isDragging = false
      let currentX, currentY, initialX, initialY

      header.addEventListener('mousedown', (e) => {
        isDragging = true
        initialX = e.clientX - info.offsetLeft
        initialY = e.clientY - info.offsetTop
      })

      document.addEventListener('mousemove', (e) => {
        if (isDragging) {
          e.preventDefault()
          currentX = e.clientX - initialX
          currentY = e.clientY - initialY
          info.style.left = currentX + 'px'
          info.style.top = currentY + 'px'
          info.style.right = 'auto'
        }
      })

      document.addEventListener('mouseup', () => {
        isDragging = false
      })
    }
  }

  startDrag(event) {
    // Non iniziare drag se stiamo cliccando sul resize handle
    if (event.target.dataset.resizeHandle !== undefined) {
      return
    }

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

  startResize(event, hotspot) {
    event.preventDefault()
    event.stopPropagation()

    this.resizing = hotspot
    this.startX = event.clientX
    this.startY = event.clientY

    // Dimensioni correnti in percentuale
    this.startWidth = parseFloat(this.resizing.style.width)
    this.startHeight = parseFloat(this.resizing.style.height)

    // Aggiungi classe visual feedback
    this.resizing.classList.add('ring-4', 'ring-blue-400', 'z-50')

    // Bind events
    this.boundMouseMove = this.resize.bind(this)
    this.boundMouseUp = this.stopResize.bind(this)

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

  resize(event) {
    if (!this.resizing) return

    event.preventDefault()

    const containerRect = this.containerTarget.getBoundingClientRect()
    const deltaX = event.clientX - this.startX
    const deltaY = event.clientY - this.startY

    // Calcola percentuali
    const deltaWidthPercent = (deltaX / containerRect.width) * 100
    const deltaHeightPercent = (deltaY / containerRect.height) * 100

    let newWidth = this.startWidth + deltaWidthPercent
    let newHeight = this.startHeight + deltaHeightPercent

    // Dimensioni minime
    newWidth = Math.max(2, newWidth)
    newHeight = Math.max(2, newHeight)

    // Non superare i bordi del contenitore
    const currentLeft = parseFloat(this.resizing.style.left)
    const currentTop = parseFloat(this.resizing.style.top)

    newWidth = Math.min(newWidth, 100 - currentLeft)
    newHeight = Math.min(newHeight, 100 - currentTop)

    // Applica nuove dimensioni
    this.resizing.style.width = `${newWidth}%`
    this.resizing.style.height = `${newHeight}%`

    // Aggiorna info panel in tempo reale
    this.updateInfoPanel()
  }

  stopResize(event) {
    if (!this.resizing) return

    // Rimuovi visual feedback
    this.resizing.classList.remove('ring-4', 'ring-blue-400', 'z-50')

    // Aggiorna info finale
    this.updateInfoPanel()

    // Log in console
    const label = this.resizing.querySelector('.sr-only')?.textContent || 'Unknown'
    console.log(`{ label: "${label}", top: "${this.resizing.style.top}", left: "${this.resizing.style.left}", width: "${this.resizing.style.width}", height: "${this.resizing.style.height}" },`)

    // Cleanup
    document.removeEventListener('mousemove', this.boundMouseMove)
    document.removeEventListener('mouseup', this.boundMouseUp)

    this.resizing = null
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

    const code = hotspots.map(h =>
      `        { label: "${h.label}", top: "${h.top}", left: "${h.left}", width: "${h.width}", height: "${h.height}" }`
    ).join(',\n')

    valuesDiv.innerHTML = `<pre class="text-xs leading-relaxed">${code}</pre>`
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

  hotspotTargetConnected(element) {
    // Aggiungi resize handle quando un nuovo hotspot viene aggiunto
    if (!element.querySelector('[data-resize-handle]')) {
      const handle = document.createElement('div')
      handle.dataset.resizeHandle = ''
      handle.className = 'absolute bottom-0 right-0 w-3 h-3 bg-white border-2 border-current rounded-full cursor-nwse-resize'
      handle.addEventListener('mousedown', (e) => this.startResize(e, element))
      element.appendChild(handle)
    }
  }

  disconnect() {
    // Cleanup info panel
    if (this.hasInfoTarget) {
      this.infoTarget.remove()
    }
  }
}
