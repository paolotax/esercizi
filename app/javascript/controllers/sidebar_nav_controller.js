import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar-nav"
export default class extends Controller {
  static targets = ["item", "children", "collapseAllButton"]

  connect() {
    // Ottieni il contenitore scrollabile della sidebar
    this.sidebarElement = document.getElementById('sidebar-nav')

    // Controlla se c'è uno stato salvato, altrimenti forza lo stato iniziale
    const hasSavedState = localStorage.getItem('sidebar-open-items')
    
    if (!hasSavedState) {
      // FORZA LO STATO INIZIALE: tutto chiuso (Stato 1) solo se non c'è stato salvato
      this.forceInitialState()
    } else {
      // Ripristina lo stato salvato
      this.restoreState()
    }

    // Ripristina lo scroll position
    this.restoreScrollPosition()

    // Aggiorna lo stato iniziale del pulsante collapse all
    setTimeout(() => {
      this.updateCollapseAllButtonState()
      // Evidenzia la pagina corrente (apre solo i volumi/discipline necessari)
      this.highlightCurrentPage()
    }, 0)

    // Listener per aggiornare l'evidenziazione e lo stato dopo ogni navigazione Turbo
    this.turboLoadHandler = () => {
      // Piccolo delay per assicurarsi che il DOM sia aggiornato
      setTimeout(() => {
        // Ripristina lo stato salvato
        this.restoreState()
        this.restoreScrollPosition()
        // Evidenzia la pagina corrente (apre i livelli necessari)
        this.highlightCurrentPage()
        this.updateCollapseAllButtonState()
      }, 0)
    }

    this.turboFrameLoadHandler = () => {
      setTimeout(() => {
        // Ripristina lo stato salvato
        this.restoreState()
        this.restoreScrollPosition()
        // Evidenzia la pagina corrente (apre i livelli necessari)
        this.highlightCurrentPage()
        this.updateCollapseAllButtonState()
      }, 0)
    }

    // Listener per turbo:before-visit per salvare lo stato prima della navigazione
    this.turboBeforeVisitHandler = () => {
      // Salva lo stato corrente prima della navigazione
      this.saveCurrentState()
      this.saveScrollPosition()
    }

    // Salva scroll anche prima del render
    this.turboBeforeRenderHandler = () => {
      this.saveScrollPosition()
    }

    document.addEventListener('turbo:load', this.turboLoadHandler)
    document.addEventListener('turbo:frame-load', this.turboFrameLoadHandler)
    document.addEventListener('turbo:before-visit', this.turboBeforeVisitHandler)
    document.addEventListener('turbo:before-render', this.turboBeforeRenderHandler)

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
    if (this.turboBeforeRenderHandler) {
      document.removeEventListener('turbo:before-render', this.turboBeforeRenderHandler)
    }
  }

  saveScrollPosition() {
    if (this.sidebarElement) {
      const scrollTop = this.sidebarElement.scrollTop
      localStorage.setItem('sidebar-scroll-position', scrollTop.toString())
    }
  }

  restoreScrollPosition() {
    if (this.sidebarElement) {
      const savedScroll = localStorage.getItem('sidebar-scroll-position')
      if (savedScroll) {
        this.sidebarElement.scrollTop = parseInt(savedScroll, 10)
      }
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

    // Salva la posizione di scroll corrente
    const currentScroll = this.sidebarElement ? this.sidebarElement.scrollTop : 0

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

      // Mantieni la posizione di scroll fissa dopo l'animazione
      requestAnimationFrame(() => {
        if (this.sidebarElement) {
          this.sidebarElement.scrollTop = currentScroll
          // Salva anche in localStorage per la navigazione
          this.saveScrollPosition()
        }
        // Aggiorna lo stato del pulsante collapse all
        this.updateCollapseAllButtonState()
      })
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

  forceInitialState() {
    // Forza tutto in stato chiuso (Stato 1) - NASCONDI COMPLETAMENTE I VOLUMI
    // Trova tutti i container dei volumi e nascondili completamente
    const volumeContainers = this.element.querySelectorAll('[data-volume-container]')
    volumeContainers.forEach(container => {
      container.style.display = 'none'
    })

    // Chiudi anche tutti i volumi e le discipline (per sicurezza)
    const volumeButtons = Array.from(this.element.querySelectorAll('button[data-sidebar-item-id]'))
      .filter(button => {
        const itemId = button.getAttribute('data-sidebar-item-id')
        return itemId && itemId.startsWith('volume-')
      })

    const disciplinaButtons = Array.from(this.element.querySelectorAll('button[data-sidebar-item-id]'))
      .filter(button => {
        const itemId = button.getAttribute('data-sidebar-item-id')
        return itemId && itemId.startsWith('disciplina-')
      })

    // Chiudi tutti i volumi
    volumeButtons.forEach(button => {
      const itemId = button.getAttribute('data-sidebar-item-id')
      let childrenContainer = button.nextElementSibling

      if (!childrenContainer || !childrenContainer.classList.contains('sidebar-children')) {
        childrenContainer = this.element.querySelector(`[data-sidebar-children-id="${itemId}"]`)
      }

      if (childrenContainer && childrenContainer.classList.contains('sidebar-children')) {
        childrenContainer.classList.remove('open')
        button.querySelector('.toggle-icon')?.classList.remove('rotate-90')
      }
    })

    // Chiudi tutte le discipline (pagine)
    disciplinaButtons.forEach(button => {
      const itemId = button.getAttribute('data-sidebar-item-id')
      let childrenContainer = button.nextElementSibling

      if (!childrenContainer || !childrenContainer.classList.contains('sidebar-children')) {
        childrenContainer = this.element.querySelector(`[data-sidebar-children-id="${itemId}"]`)
      }

      if (childrenContainer && childrenContainer.classList.contains('sidebar-children')) {
        childrenContainer.classList.remove('open')
        button.querySelector('.toggle-icon')?.classList.remove('rotate-90')
      }
    })

    // Pulisci localStorage per i volumi e discipline (mantieni solo lo scroll)
    localStorage.removeItem('sidebar-open-items')
  }

  restoreState() {
    const openItems = this.getOpenItems()
    
    if (openItems.length === 0) {
      // Aggiorna lo stato del pulsante se non ci sono item aperti
      this.updateCollapseAllButtonState()
      return
    }

    // Determina se ci sono volumi o discipline aperti
    const hasOpenVolumes = openItems.some(itemId => itemId.startsWith('volume-'))
    const hasOpenDisciplinas = openItems.some(itemId => itemId.startsWith('disciplina-'))

    // Mostra i volumi se ci sono volumi salvati come aperti
    const volumeContainers = this.element.querySelectorAll('[data-volume-container]')
    if (hasOpenVolumes) {
      volumeContainers.forEach(container => {
        container.style.display = ''
      })
    }

    // Le discipline sono sempre visibili quando i volumi sono aperti
    // Non usare display: none, solo gestire l'apertura/chiusura dei loro sidebar-children

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

    // Aggiorna lo stato del pulsante dopo il ripristino
    this.updateCollapseAllButtonState()
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
                
                // Se apriamo un volume, mostra anche il container del volume
                if (itemId.startsWith('volume-')) {
                  const volumeContainer = this.element.querySelector(`[data-volume-container="${itemId}"]`)
                  if (volumeContainer) {
                    volumeContainer.style.display = ''
                  }
                }
              }
            }
          }
          parent = parent.parentElement
        }
      }
    })

    // Aggiorna lo stato del pulsante collapse all dopo l'evidenziazione
    this.updateCollapseAllButtonState()
  }

  toggleAllVolumes(event) {
    event.preventDefault()
    
    // Trova tutti i volumi (elementi con data-sidebar-item-id che iniziano con "volume-")
    const volumeButtons = Array.from(this.element.querySelectorAll('button[data-sidebar-item-id]'))
      .filter(button => {
        const itemId = button.getAttribute('data-sidebar-item-id')
        return itemId && itemId.startsWith('volume-')
      })

    // Trova tutte le discipline (elementi con data-sidebar-item-id che iniziano con "disciplina-")
    const disciplinaButtons = Array.from(this.element.querySelectorAll('button[data-sidebar-item-id]'))
      .filter(button => {
        const itemId = button.getAttribute('data-sidebar-item-id')
        return itemId && itemId.startsWith('disciplina-')
      })

    if (volumeButtons.length === 0) return

    // Controlla se i volumi sono visibili (non nascosti)
    const volumeContainers = this.element.querySelectorAll('[data-volume-container]')
    let volumesVisible = true
    if (volumeContainers.length > 0) {
      volumesVisible = volumeContainers[0].style.display !== 'none'
    }

    // Determina lo stato attuale:
    // - Stato 1: tutti i volumi nascosti (display: none) - tutto chiuso
    // - Stato 2: tutti i volumi visibili, tutti i volumi aperti, tutte le discipline chiuse
    // - Stato 3: tutti i volumi visibili, tutti i volumi aperti, tutte le discipline aperte
    let allVolumesOpen = true
    let allVolumesClosed = true
    let allDisciplinasOpen = true
    let allDisciplinasClosed = true

    // Controlla lo stato solo se i volumi sono visibili
    if (volumesVisible) {
      volumeButtons.forEach(button => {
        const itemId = button.getAttribute('data-sidebar-item-id')
        let childrenContainer = button.nextElementSibling

        if (!childrenContainer || !childrenContainer.classList.contains('sidebar-children')) {
          childrenContainer = this.element.querySelector(`[data-sidebar-children-id="${itemId}"]`)
        }

        if (childrenContainer && childrenContainer.classList.contains('sidebar-children')) {
          if (childrenContainer.classList.contains('open')) {
            allVolumesClosed = false
          } else {
            allVolumesOpen = false
          }
        }
      })

      // Controlla lo stato delle discipline solo se i volumi sono aperti
      if (allVolumesOpen) {
        disciplinaButtons.forEach(button => {
          const itemId = button.getAttribute('data-sidebar-item-id')
          let childrenContainer = button.nextElementSibling

          if (!childrenContainer || !childrenContainer.classList.contains('sidebar-children')) {
            childrenContainer = this.element.querySelector(`[data-sidebar-children-id="${itemId}"]`)
          }

          if (childrenContainer && childrenContainer.classList.contains('sidebar-children')) {
            if (childrenContainer.classList.contains('open')) {
              allDisciplinasClosed = false
            } else {
              allDisciplinasOpen = false
            }
          }
        })
      }
    }

    // Determina la prossima azione basandosi sullo stato:
    let action = 'open-volumes' // default: apri i volumi

    if (!volumesVisible || (volumesVisible && allVolumesClosed)) {
      // Stato 1: Volumi nascosti o tutti chiusi -> Apri i volumi (ma non le discipline)
      action = 'open-volumes'
    } else if (volumesVisible && allVolumesOpen && allDisciplinasClosed) {
      // Stato 2: Volumi aperti, discipline chiuse -> Apri le discipline (espandi tutto)
      action = 'open-all'
    } else if (volumesVisible && allVolumesOpen && allDisciplinasOpen) {
      // Stato 3: Tutto aperto -> Chiudi tutto (ritorna allo stato 1)
      action = 'close-all'
    } else {
      // Stato misto (alcuni volumi aperti, alcuni chiusi): 
      // Normalizza aprendo tutto (Stato 3)
      action = 'open-all'
    }

    // Salva la posizione di scroll corrente
    const currentScroll = this.sidebarElement ? this.sidebarElement.scrollTop : 0

    if (action === 'open-volumes') {
      // Stato 1 -> Stato 2: MOSTRA i volumi e aprilì, ma CHIUDI le discipline (collassate, non nascoste)
      // Mostra tutti i container dei volumi
      const volumeContainers = this.element.querySelectorAll('[data-volume-container]')
      volumeContainers.forEach(container => {
        container.style.display = ''
      })

      // Apri tutti i volumi (mostra il container delle discipline, ma le discipline sono chiuse)
      volumeButtons.forEach(button => {
        const itemId = button.getAttribute('data-sidebar-item-id')
        let childrenContainer = button.nextElementSibling

        if (!childrenContainer || !childrenContainer.classList.contains('sidebar-children')) {
          childrenContainer = this.element.querySelector(`[data-sidebar-children-id="${itemId}"]`)
        }

        if (childrenContainer && childrenContainer.classList.contains('sidebar-children')) {
          childrenContainer.classList.add('open')
          button.querySelector('.toggle-icon')?.classList.add('rotate-90')
          this.saveOpenState(itemId)
        }
      })

      // CHIUDI tutte le discipline (le pagine sono collassate, ma le discipline sono visibili)
      // NON usare display: none, solo chiudi i loro sidebar-children
      disciplinaButtons.forEach(button => {
        const itemId = button.getAttribute('data-sidebar-item-id')
        let childrenContainer = button.nextElementSibling

        if (!childrenContainer || !childrenContainer.classList.contains('sidebar-children')) {
          childrenContainer = this.element.querySelector(`[data-sidebar-children-id="${itemId}"]`)
        }

        if (childrenContainer && childrenContainer.classList.contains('sidebar-children')) {
          childrenContainer.classList.remove('open')
          button.querySelector('.toggle-icon')?.classList.remove('rotate-90')
          this.saveClosedState(itemId)
        }
      })
    } else if (action === 'open-all') {
      // Stato 2 -> Stato 3: APRI tutte le discipline (tutto espanso)
      // Assicurati che tutti i volumi siano visibili e aperti
      const volumeContainers = this.element.querySelectorAll('[data-volume-container]')
      volumeContainers.forEach(container => {
        container.style.display = ''
      })

      // Apri tutti i volumi (se non sono già tutti aperti)
      volumeButtons.forEach(button => {
        const itemId = button.getAttribute('data-sidebar-item-id')
        let childrenContainer = button.nextElementSibling

        if (!childrenContainer || !childrenContainer.classList.contains('sidebar-children')) {
          childrenContainer = this.element.querySelector(`[data-sidebar-children-id="${itemId}"]`)
        }

        if (childrenContainer && childrenContainer.classList.contains('sidebar-children')) {
          if (!childrenContainer.classList.contains('open')) {
            childrenContainer.classList.add('open')
            button.querySelector('.toggle-icon')?.classList.add('rotate-90')
            this.saveOpenState(itemId)
          }
        }
      })

      // Apri tutte le discipline (mostra le pagine) - Stato 3
      // Le discipline sono già visibili, basta aprire i loro sidebar-children
      disciplinaButtons.forEach(button => {
        const itemId = button.getAttribute('data-sidebar-item-id')
        let childrenContainer = button.nextElementSibling

        if (!childrenContainer || !childrenContainer.classList.contains('sidebar-children')) {
          childrenContainer = this.element.querySelector(`[data-sidebar-children-id="${itemId}"]`)
        }

        if (childrenContainer && childrenContainer.classList.contains('sidebar-children')) {
          childrenContainer.classList.add('open')
          button.querySelector('.toggle-icon')?.classList.add('rotate-90')
          this.saveOpenState(itemId)
        }
      })
    } else if (action === 'close-all') {
      // Stato 3 -> Stato 1: NASCONDI completamente i volumi (e chiudi tutto)
      // Nascondi tutti i container dei volumi
      const volumeContainers = this.element.querySelectorAll('[data-volume-container]')
      volumeContainers.forEach(container => {
        container.style.display = 'none'
      })

      // Chiudi tutti i volumi
      volumeButtons.forEach(button => {
        const itemId = button.getAttribute('data-sidebar-item-id')
        let childrenContainer = button.nextElementSibling

        if (!childrenContainer || !childrenContainer.classList.contains('sidebar-children')) {
          childrenContainer = this.element.querySelector(`[data-sidebar-children-id="${itemId}"]`)
        }

        if (childrenContainer && childrenContainer.classList.contains('sidebar-children')) {
          childrenContainer.classList.remove('open')
          button.querySelector('.toggle-icon')?.classList.remove('rotate-90')
          this.saveClosedState(itemId)
        }
      })

      // Chiudi tutte le discipline (le pagine)
      disciplinaButtons.forEach(button => {
        const itemId = button.getAttribute('data-sidebar-item-id')
        let childrenContainer = button.nextElementSibling

        if (!childrenContainer || !childrenContainer.classList.contains('sidebar-children')) {
          childrenContainer = this.element.querySelector(`[data-sidebar-children-id="${itemId}"]`)
        }

        if (childrenContainer && childrenContainer.classList.contains('sidebar-children')) {
          childrenContainer.classList.remove('open')
          button.querySelector('.toggle-icon')?.classList.remove('rotate-90')
          this.saveClosedState(itemId)
        }
      })
    }

    // Aggiorna l'icona del pulsante in base allo stato finale
    this.updateCollapseAllButtonState()

    // Mantieni la posizione di scroll fissa dopo l'animazione
    requestAnimationFrame(() => {
      if (this.sidebarElement) {
        this.sidebarElement.scrollTop = currentScroll
        this.saveScrollPosition()
      }
    })
  }

  updateCollapseAllButtonState() {
    // Trova tutti i volumi e le discipline
    const volumeButtons = Array.from(this.element.querySelectorAll('button[data-sidebar-item-id]'))
      .filter(button => {
        const itemId = button.getAttribute('data-sidebar-item-id')
        return itemId && itemId.startsWith('volume-')
      })

    const disciplinaButtons = Array.from(this.element.querySelectorAll('button[data-sidebar-item-id]'))
      .filter(button => {
        const itemId = button.getAttribute('data-sidebar-item-id')
        return itemId && itemId.startsWith('disciplina-')
      })

    if (volumeButtons.length === 0) return

    if (this.hasCollapseAllButtonTarget) {
      const icon = this.collapseAllButtonTarget.querySelector('svg')
      if (!icon) return

      // Controlla se i volumi sono visibili
      const volumeContainers = this.element.querySelectorAll('[data-volume-container]')
      let volumesVisible = true
      if (volumeContainers.length > 0) {
        volumesVisible = volumeContainers[0].style.display !== 'none'
      }

      // Determina lo stato corrente
      let allVolumesOpen = true
      let allVolumesClosed = true
      let allDisciplinasOpen = true
      let allDisciplinasClosed = true

      if (volumesVisible) {
        volumeButtons.forEach(button => {
          const itemId = button.getAttribute('data-sidebar-item-id')
          let childrenContainer = button.nextElementSibling

          if (!childrenContainer || !childrenContainer.classList.contains('sidebar-children')) {
            childrenContainer = this.element.querySelector(`[data-sidebar-children-id="${itemId}"]`)
          }

          if (childrenContainer && childrenContainer.classList.contains('sidebar-children')) {
            if (childrenContainer.classList.contains('open')) {
              allVolumesClosed = false
            } else {
              allVolumesOpen = false
            }
          }
        })

        if (allVolumesOpen) {
          disciplinaButtons.forEach(button => {
            const itemId = button.getAttribute('data-sidebar-item-id')
            let childrenContainer = button.nextElementSibling

            if (!childrenContainer || !childrenContainer.classList.contains('sidebar-children')) {
              childrenContainer = this.element.querySelector(`[data-sidebar-children-id="${itemId}"]`)
            }

            if (childrenContainer && childrenContainer.classList.contains('sidebar-children')) {
              if (childrenContainer.classList.contains('open')) {
                allDisciplinasClosed = false
              } else {
                allDisciplinasOpen = false
              }
            }
          })
        }
      }

      // Rimuovi tutte le rotazioni precedenti
      icon.classList.remove('-rotate-90', '-rotate-180')

      // Applica la rotazione in base allo stato:
      // - Stato 1 (volumi nascosti o tutto chiuso): 0 gradi
      // - Stato 2 (volumi aperti, discipline chiuse): -90 gradi
      // - Stato 3 (tutto aperto): -180 gradi (altri 90 gradi)
      if (!volumesVisible || (volumesVisible && allVolumesClosed)) {
        // Stato 1: nessuna rotazione
        icon.classList.remove('-rotate-90', '-rotate-180')
      } else if (volumesVisible && allVolumesOpen && allDisciplinasClosed) {
        // Stato 2: rotazione di -90 gradi
        icon.classList.add('-rotate-90')
      } else if (volumesVisible && allVolumesOpen && allDisciplinasOpen) {
        // Stato 3: rotazione di -180 gradi (altri 90 gradi)
        icon.classList.add('-rotate-180')
      } else {
        // Stato misto: usa -90 come default
        icon.classList.add('-rotate-90')
      }
    }
  }
}
