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
    this.editMode = false

    // Aggiungi info panel se non esiste (nascosto di default)
    this.createInfoPanel()

    // Aggiungi resize handles a tutti gli hotspot
    this.addResizeHandles()

    // Aggiungi pulsante edit alla pagina
    this.createEditButton()
  }

  addResizeHandles() {
    this.hotspotTargets.forEach(hotspot => {
      if (!hotspot.querySelector('[data-resize-handle]')) {
        const handle = document.createElement('div')
        handle.dataset.resizeHandle = ''
        handle.className = 'absolute bottom-0 right-0 w-3 h-3 bg-white border-2 border-current rounded-full cursor-nwse-resize hidden'
        handle.addEventListener('mousedown', (e) => this.startResize(e, hotspot))
        hotspot.appendChild(handle)
      }
    })
  }

  createEditButton() {
    const editBtn = document.createElement('button')
    editBtn.className = "fixed bottom-4 right-4 bg-yellow-500 hover:bg-yellow-600 text-white font-bold px-4 py-2 rounded-lg shadow-2xl z-40 transition"
    editBtn.textContent = "✏️ Edit Hotspots"
    editBtn.addEventListener('click', () => this.toggleEditMode())
    document.body.appendChild(editBtn)
    this.editButton = editBtn
  }

  createInfoPanel() {
    if (!this.hasInfoTarget) {
      const info = document.createElement('div')
      info.dataset.hotspotEditorTarget = "info"
      info.className = "fixed top-4 right-4 bg-white border-4 border-blue-500 rounded-lg shadow-2xl z-50 hidden"
      info.style.width = "600px"
      info.innerHTML = `
        <div class="bg-blue-500 text-white px-3 py-2 font-bold text-sm flex items-center justify-between cursor-move" data-panel-header>
          <span>Hotspot Values (drag to move)</span>
          <div class="flex gap-2">
            <button class="bg-white text-blue-600 px-3 py-1 rounded font-bold hover:bg-blue-50 transition cursor-pointer" data-copy-button>
              Copy
            </button>
            <button class="bg-red-500 text-white px-3 py-1 rounded font-bold hover:bg-red-600 transition cursor-pointer" data-close-button>
              Close
            </button>
          </div>
        </div>
        <div id="hotspot-values" class="font-mono text-xs bg-gray-100 p-3 max-h-96 overflow-y-auto"></div>
      `
      document.body.appendChild(info)

      // Add copy button handler
      const copyButton = info.querySelector('[data-copy-button]')
      copyButton.addEventListener('click', (e) => {
        e.stopPropagation()
        this.copyToClipboard()
      })

      // Add close button handler
      const closeButton = info.querySelector('[data-close-button]')
      closeButton.addEventListener('click', (e) => {
        e.stopPropagation()
        this.toggleEditMode()
      })

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
    // Non iniziare drag se non siamo in edit mode
    if (!this.editMode) {
      return
    }

    // Non iniziare drag se stiamo cliccando sul resize handle
    if (event.target.dataset.resizeHandle !== undefined) {
      return
    }

    event.preventDefault()

    this.dragging = event.currentTarget
    const rect = this.dragging.getBoundingClientRect()

    // Trova il container parent specifico per questo hotspot
    this.currentContainer = this.dragging.closest('[data-hotspot-editor-target="container"]')
    const containerRect = this.currentContainer.getBoundingClientRect()

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
    if (!this.dragging || !this.currentContainer) return

    event.preventDefault()

    const containerRect = this.currentContainer.getBoundingClientRect()
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
    this.currentContainer = null
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

  copyToClipboard() {
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

    navigator.clipboard.writeText(code).then(() => {
      // Visual feedback
      const copyButton = document.querySelector('[data-copy-button]')
      if (copyButton) {
        const originalText = copyButton.textContent
        copyButton.textContent = 'Copied!'
        copyButton.classList.add('bg-green-500', 'text-white')
        copyButton.classList.remove('bg-white', 'text-blue-600')

        setTimeout(() => {
          copyButton.textContent = originalText
          copyButton.classList.remove('bg-green-500', 'text-white')
          copyButton.classList.add('bg-white', 'text-blue-600')
        }, 2000)
      }
      console.log('Copied to clipboard:\n' + code)
    }).catch(err => {
      console.error('Failed to copy:', err)
      alert('Errore durante la copia. Seleziona e copia manualmente.')
    })
  }

  hotspotTargetConnected(element) {
    // Aggiungi resize handle quando un nuovo hotspot viene aggiunto (nascosto di default)
    if (!element.querySelector('[data-resize-handle]')) {
      const handle = document.createElement('div')
      handle.dataset.resizeHandle = ''
      handle.className = 'absolute bottom-0 right-0 w-3 h-3 bg-white border-2 border-current rounded-full cursor-nwse-resize hidden'
      handle.addEventListener('mousedown', (e) => this.startResize(e, element))
      element.appendChild(handle)
    }
  }

  toggleEditMode() {
    this.editMode = !this.editMode
    const info = document.querySelector('[data-hotspot-editor-target="info"]')

    if (this.editMode) {
      // Attiva modalità edit
      info.classList.remove('hidden')
      this.editButton.textContent = "👁️ View Mode"
      this.editButton.classList.remove('bg-yellow-500', 'hover:bg-yellow-600')
      this.editButton.classList.add('bg-green-500', 'hover:bg-green-600')

      // Rendi hotspot completamente visibili e mostra resize handles
      this.hotspotTargets.forEach(hotspot => {
        const currentBg = hotspot.className
        // Rimuovi /10 dall'opacità
        hotspot.className = currentBg.replace(/bg-(\w+)-(\d+)\/10/, 'bg-$1-$2')

        // Aggiungi cursor-move per indicare draggabilità
        hotspot.classList.add('cursor-move')

        // Mostra resize handle
        const handle = hotspot.querySelector('[data-resize-handle]')
        if (handle) {
          handle.classList.remove('hidden')
        }
      })

      this.updateInfoPanel()
    } else {
      // Disattiva modalità edit
      info.classList.add('hidden')
      this.editButton.textContent = "✏️ Edit Hotspots"
      this.editButton.classList.remove('bg-green-500', 'hover:bg-green-600')
      this.editButton.classList.add('bg-yellow-500', 'hover:bg-yellow-600')

      // Rimetti hotspot semi-trasparenti e nascondi resize handles
      this.hotspotTargets.forEach(hotspot => {
        const currentBg = hotspot.className
        // Aggiungi /10 all'opacità se non c'è già
        if (!currentBg.includes('/10')) {
          hotspot.className = currentBg.replace(/bg-(\w+)-(\d+)(?!\/)/, 'bg-$1-$2/10')
        }

        // Rimuovi cursor-move
        hotspot.classList.remove('cursor-move')

        // Nascondi resize handle
        const handle = hotspot.querySelector('[data-resize-handle]')
        if (handle) {
          handle.classList.add('hidden')
        }
      })
    }
  }

  disconnect() {
    // Cleanup
    if (this.hasInfoTarget) {
      this.infoTarget.remove()
    }
    if (this.editButton) {
      this.editButton.remove()
    }
  }
}
