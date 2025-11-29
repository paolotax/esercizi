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
    // Crea pulsante Edit dentro il container (non globale)
    const editBtn = document.createElement('button')
    editBtn.className = "absolute top-2 right-2 bg-yellow-500 hover:bg-yellow-600 text-white font-bold px-3 py-1 rounded-lg shadow-lg z-40 transition text-sm opacity-50 hover:opacity-100"
    editBtn.textContent = "✏️ Edit"
    editBtn.addEventListener('click', (e) => {
      e.preventDefault()
      e.stopPropagation()
      this.toggleEditMode()
    })

    // Aggiungi al container, non al body
    this.containerTarget.appendChild(editBtn)
    this.editButton = editBtn
  }

  createInfoPanel() {
    // Genera un ID unico per questo controller
    this.panelId = `hotspot-values-${Math.random().toString(36).substr(2, 9)}`

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
      <div id="${this.panelId}" class="font-mono text-xs bg-gray-100 p-3 max-h-96 overflow-y-auto"></div>
    `
    document.body.appendChild(info)
    this.infoPanel = info

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
    const label = this.getHotspotLabel(this.resizing)
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
    const label = this.getHotspotLabel(this.dragging)
    console.log(`{ label: "${label}", top: "${this.dragging.style.top}", left: "${this.dragging.style.left}", width: "${this.dragging.style.width}", height: "${this.dragging.style.height}" },`)

    // Cleanup
    document.removeEventListener('mousemove', this.boundMouseMove)
    document.removeEventListener('mouseup', this.boundMouseUp)

    this.dragging = null
    this.currentContainer = null
  }

  getHotspotLabel(hotspot) {
    // Cerca in ordine: .sr-only, data-image-speech-word-value, aria-label su input, aria-label sul hotspot stesso
    return hotspot.querySelector('.sr-only')?.textContent
        || hotspot.dataset.imageSpeechWordValue
        || hotspot.querySelector('input')?.getAttribute('aria-label')
        || hotspot.querySelector('textarea')?.getAttribute('aria-label')
        || hotspot.getAttribute('aria-label')
        || 'Unknown'
  }

  getHotspotData(hotspot) {
    const label = this.getHotspotLabel(hotspot)
    const data = {
      label,
      top: hotspot.style.top,
      left: hotspot.style.left,
      width: hotspot.style.width,
      height: hotspot.style.height
    }

    // Cerca input o textarea dentro l'hotspot per estrarre answer e type
    const input = hotspot.querySelector('input')
    const textarea = hotspot.querySelector('textarea')

    if (textarea) {
      const answer = textarea.dataset.correctAnswer
      if (answer) {
        data.answer = answer
        data.type = 'textarea'
      }
    } else if (input) {
      const answer = input.dataset.correctAnswer
      if (answer) {
        data.answer = answer
      }
    }

    return data
  }

  formatHotspotCode(h) {
    let parts = [
      `label: "${h.label}"`,
      `top: "${h.top}"`,
      `left: "${h.left}"`,
      `width: "${h.width}"`,
      `height: "${h.height}"`
    ]
    if (h.answer !== undefined) {
      parts.push(`answer: "${h.answer}"`)
    }
    if (h.type) {
      parts.push(`type: "${h.type}"`)
    }
    return `        { ${parts.join(', ')} }`
  }

  updateInfoPanel() {
    const valuesDiv = document.getElementById(this.panelId)
    if (!valuesDiv) return

    const hotspots = this.hotspotTargets.map(hotspot => this.getHotspotData(hotspot))
    const code = hotspots.map(h => this.formatHotspotCode(h)).join(',\n')

    valuesDiv.innerHTML = `<pre class="text-xs leading-relaxed">${code}</pre>`
  }

  copyToClipboard() {
    const hotspots = this.hotspotTargets.map(hotspot => this.getHotspotData(hotspot))
    const code = hotspots.map(h => this.formatHotspotCode(h)).join(',\n')

    navigator.clipboard.writeText(code).then(() => {
      // Visual feedback - usa il pulsante del proprio panel
      const copyButton = this.infoPanel.querySelector('[data-copy-button]')
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
    const info = this.infoPanel

    if (this.editMode) {
      // Attiva modalità edit
      info.classList.remove('hidden')
      this.editButton.textContent = "👁️ View"
      this.editButton.classList.remove('bg-yellow-500', 'hover:bg-yellow-600')
      this.editButton.classList.add('bg-green-500', 'hover:bg-green-600')

      // Rendi hotspot completamente visibili e mostra resize handles
      this.hotspotTargets.forEach(hotspot => {
        const currentBg = hotspot.className
        // Rimuovi /10 dall'opacità
        hotspot.className = currentBg.replace(/bg-(\w+)-(\d+)\/10/, 'bg-$1-$2')

        // Aggiungi bordo dotted grigio scuro
        hotspot.classList.remove('border-transparent')
        hotspot.classList.add('border-2', 'border-dashed', 'border-gray-700')

        // Aggiungi label visibile centrata
        if (!hotspot.querySelector('[data-hotspot-label]')) {
          const label = this.getHotspotLabel(hotspot)
          const labelSpan = document.createElement('span')
          labelSpan.dataset.hotspotLabel = ''
          labelSpan.className = 'absolute inset-0 flex items-center justify-center text-xs font-bold text-gray-800 bg-white/70 rounded pointer-events-none'
          labelSpan.textContent = label
          hotspot.appendChild(labelSpan)
        }

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
      this.editButton.textContent = "✏️ Edit"
      this.editButton.classList.remove('bg-green-500', 'hover:bg-green-600')
      this.editButton.classList.add('bg-yellow-500', 'hover:bg-yellow-600')

      // Rimetti hotspot semi-trasparenti e nascondi resize handles
      this.hotspotTargets.forEach(hotspot => {
        const currentBg = hotspot.className
        // Aggiungi /10 all'opacità se non c'è già
        if (!currentBg.includes('/10')) {
          hotspot.className = currentBg.replace(/bg-(\w+)-(\d+)(?!\/)/, 'bg-$1-$2/10')
        }

        // Rimuovi bordo dotted, rimetti trasparente
        hotspot.classList.remove('border-dashed', 'border-gray-700')
        hotspot.classList.add('border-transparent')

        // Rimuovi label visibile
        const labelSpan = hotspot.querySelector('[data-hotspot-label]')
        if (labelSpan) labelSpan.remove()

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
    if (this.infoPanel) {
      this.infoPanel.remove()
    }
    if (this.editButton) {
      this.editButton.remove()
    }
  }
}
