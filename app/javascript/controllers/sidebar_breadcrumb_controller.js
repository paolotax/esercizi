import { Controller } from "@hotwired/stimulus"

// Navigazione sidebar con breadcrumb
// Livelli: HOME → Corsi → Volumi → Discipline → Pagine
export default class extends Controller {
  static targets = ["content", "data", "title", "backButton"]

  connect() {
    // Stato della navigazione
    this.navigationState = {
      level: 'corsi', // corsi, volumi, discipline, pagine
      corsoId: null,
      corsoNome: null,
      volumeId: null,
      volumeNome: null,
      disciplinaId: null,
      disciplinaNome: null
    }

    // Riferimento alla sidebar per salvare scroll
    this.sidebar = document.getElementById('sidebar-nav')

    // Carica stato salvato o inizia dai corsi
    this.loadState()
    this.render()

    // Salva e ripristina scroll quando si naviga con Turbo
    this.boundBeforeVisit = this.saveScrollPosition.bind(this)
    this.boundAfterRender = this.restoreScrollPosition.bind(this)

    document.addEventListener('turbo:before-visit', this.boundBeforeVisit)
    document.addEventListener('turbo:render', this.boundAfterRender)
  }

  disconnect() {
    if (this.boundBeforeVisit) {
      document.removeEventListener('turbo:before-visit', this.boundBeforeVisit)
    }
    if (this.boundAfterRender) {
      document.removeEventListener('turbo:render', this.boundAfterRender)
    }
  }

  saveScrollPosition() {
    if (this.sidebar) {
      localStorage.setItem('sidebar-scroll-position', this.sidebar.scrollTop)
    }
  }

  restoreScrollPosition() {
    if (this.sidebar) {
      const scrollPos = localStorage.getItem('sidebar-scroll-position')
      if (scrollPos !== null) {
        // Usa setTimeout per assicurarsi che il DOM sia aggiornato
        setTimeout(() => {
          this.sidebar.scrollTop = parseInt(scrollPos, 10)
        }, 0)
      }
    }
  }

  goBack(event) {
    event.preventDefault()

    const { level } = this.navigationState

    if (level === 'volumi') {
      // Torna ai corsi
      this.goToCorsi(event)
    } else if (level === 'discipline') {
      // Torna ai volumi
      this.goToVolumi(event)
    } else if (level === 'pagine') {
      // Torna alle discipline
      this.goToDiscipline(event)
    }
  }

  goToHome(event) {
    event.preventDefault()
    this.navigationState = {
      level: 'corsi',
      corsoId: null,
      corsoNome: null,
      volumeId: null,
      volumeNome: null,
      disciplinaId: null,
      disciplinaNome: null
    }
    this.saveState()
    this.render()
  }

  selectCorso(event) {
    const button = event.currentTarget
    const corsoId = button.dataset.corsoId
    const corsoNome = button.dataset.corsoNome

    this.navigationState = {
      level: 'volumi',
      corsoId: corsoId,
      corsoNome: corsoNome,
      volumeId: null,
      volumeNome: null,
      disciplinaId: null,
      disciplinaNome: null
    }
    this.saveState()
    this.render()
  }

  selectVolume(event) {
    const button = event.currentTarget
    const volumeId = button.dataset.volumeId
    const volumeNome = button.dataset.volumeNome

    this.navigationState.level = 'discipline'
    this.navigationState.volumeId = volumeId
    this.navigationState.volumeNome = volumeNome
    this.navigationState.disciplinaId = null
    this.navigationState.disciplinaNome = null

    this.saveState()
    this.render()
  }

  selectDisciplina(event) {
    const button = event.currentTarget
    const disciplinaId = button.dataset.disciplinaId
    const disciplinaNome = button.dataset.disciplinaNome

    this.navigationState.level = 'pagine'
    this.navigationState.disciplinaId = disciplinaId
    this.navigationState.disciplinaNome = disciplinaNome

    this.saveState()
    this.render()
  }

  goToCorsi(event) {
    event.preventDefault()
    this.navigationState = {
      level: 'corsi',
      corsoId: null,
      corsoNome: null,
      volumeId: null,
      volumeNome: null,
      disciplinaId: null,
      disciplinaNome: null
    }
    this.saveState()
    this.render()
  }

  goToVolumi(event) {
    event.preventDefault()
    this.navigationState.level = 'volumi'
    this.navigationState.volumeId = null
    this.navigationState.volumeNome = null
    this.navigationState.disciplinaId = null
    this.navigationState.disciplinaNome = null
    this.saveState()
    this.render()
  }

  goToDiscipline(event) {
    event.preventDefault()
    this.navigationState.level = 'discipline'
    this.navigationState.disciplinaId = null
    this.navigationState.disciplinaNome = null
    this.saveState()
    this.render()
  }

  render() {
    this.updateTitle()
    this.updateBackButton()
    this.renderContent()
  }

  updateTitle() {
    if (!this.hasTitleTarget) return

    const { level, corsoNome, volumeNome, disciplinaNome } = this.navigationState

    let title = 'Libri di Testo'

    if (level === 'volumi' && corsoNome) {
      title = corsoNome
    } else if (level === 'discipline' && volumeNome) {
      title = volumeNome
    } else if (level === 'pagine' && disciplinaNome) {
      title = disciplinaNome
    }

    this.titleTarget.textContent = title
  }

  updateBackButton() {
    if (!this.hasBackButtonTarget) return

    const { level } = this.navigationState

    // Mostra il bottone indietro solo se NON siamo a livello corsi
    if (level === 'corsi') {
      this.backButtonTarget.classList.add('hidden')
    } else {
      this.backButtonTarget.classList.remove('hidden')
      this.backButtonTarget.classList.add('flex')
    }
  }

  renderContent() {
    const { level, corsoId, volumeId, disciplinaId } = this.navigationState

    let html = ''

    if (level === 'corsi') {
      // Mostra i corsi
      html = this.renderCorsi()
    } else if (level === 'volumi') {
      // Mostra i volumi del corso selezionato
      html = this.renderVolumi(corsoId)
    } else if (level === 'discipline') {
      // Mostra le discipline del volume selezionato
      html = this.renderDiscipline(volumeId)
    } else if (level === 'pagine') {
      // Mostra le pagine della disciplina selezionata
      html = this.renderPagine(disciplinaId)
    }

    this.contentTarget.innerHTML = html
  }

  renderCorsi() {
    // Leggi i corsi dal data target
    const corsi = Array.from(this.dataTarget.querySelectorAll('[data-corso-id]'))

    return corsi.map(corso => {
      const corsoId = corso.dataset.corsoId
      const corsoNome = corso.dataset.corsoNome
      const volumiCount = corso.querySelectorAll('[data-volume-id]').length

      return `
        <button class="w-full flex items-center justify-between gap-2 p-3 rounded-lg bg-gradient-to-r from-purple-50 to-pink-50 hover:from-purple-100 hover:to-pink-100 transition text-left group border border-purple-200"
                data-action="click->sidebar-breadcrumb#selectCorso"
                data-corso-id="${corsoId}"
                data-corso-nome="${corsoNome}">
          <div class="flex-1">
            <div class="font-bold text-gray-900">${corsoNome}</div>
            <div class="text-xs text-gray-600">${volumiCount} ${volumiCount === 1 ? 'volume' : 'volumi'}</div>
          </div>
          <svg class="w-5 h-5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
          </svg>
        </button>
      `
    }).join('')
  }

  renderVolumi(corsoId) {
    const corsoData = this.dataTarget.querySelector(`[data-corso-id="${corsoId}"]`)
    if (!corsoData) return ''

    const volumi = Array.from(corsoData.querySelectorAll('[data-volume-id]'))

    return volumi.map(volume => {
      const volumeId = volume.dataset.volumeId
      const volumeNome = volume.dataset.volumeNome
      const volumeClasse = volume.dataset.volumeClasse
      const disciplineCount = volume.querySelectorAll('[data-disciplina-id]').length

      return `
        <button class="w-full flex items-center justify-between gap-2 p-3 rounded-lg bg-gradient-to-r from-indigo-50 to-blue-50 hover:from-indigo-100 hover:to-blue-100 transition text-left group border border-indigo-200"
                data-action="click->sidebar-breadcrumb#selectVolume"
                data-volume-id="${volumeId}"
                data-volume-nome="${volumeNome}">
          <div class="flex-1">
            <div class="font-semibold text-gray-900">${volumeNome}</div>
            ${volumeClasse ? `<div class="text-xs text-gray-600">Classe ${volumeClasse}</div>` : ''}
            <div class="text-xs text-gray-500">${disciplineCount} ${disciplineCount === 1 ? 'disciplina' : 'discipline'}</div>
          </div>
          <svg class="w-5 h-5 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
          </svg>
        </button>
      `
    }).join('')
  }

  renderDiscipline(volumeId) {
    const volumeData = this.dataTarget.querySelector(`[data-volume-id="${volumeId}"]`)
    if (!volumeData) return ''

    const discipline = Array.from(volumeData.querySelectorAll('[data-disciplina-id]'))

    return discipline.map(disciplina => {
      const disciplinaId = disciplina.dataset.disciplinaId
      const disciplinaNome = disciplina.dataset.disciplinaNome
      const disciplinaColore = disciplina.dataset.disciplinaColore
      const pagineCount = disciplina.querySelectorAll('[data-pagina-id]').length

      return `
        <button class="w-full flex items-center justify-between gap-2 p-3 rounded-lg hover:bg-blue-50 transition text-left group border-l-4"
                style="border-color: ${disciplinaColore}"
                data-action="click->sidebar-breadcrumb#selectDisciplina"
                data-disciplina-id="${disciplinaId}"
                data-disciplina-nome="${disciplinaNome}">
          <div class="flex-1">
            <div class="font-semibold text-gray-900" style="color: ${disciplinaColore}">${disciplinaNome}</div>
            <div class="text-xs text-gray-500">${pagineCount} ${pagineCount === 1 ? 'pagina' : 'pagine'}</div>
          </div>
          <svg class="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
          </svg>
        </button>
      `
    }).join('')
  }

  renderPagine(disciplinaId) {
    const disciplinaData = this.dataTarget.querySelector(`[data-disciplina-id="${disciplinaId}"]`)
    if (!disciplinaData) return ''

    const disciplinaColore = disciplinaData.dataset.disciplinaColore
    const pagine = Array.from(disciplinaData.querySelectorAll('[data-pagina-id]'))

    return pagine.map(pagina => {
      const paginaNumero = pagina.dataset.paginaNumero
      const paginaTitolo = pagina.dataset.paginaTitolo
      const paginaSlug = pagina.dataset.paginaSlug

      return `
        <a href="/pagine/${paginaSlug}"
           data-turbo-frame="_top"
           class="flex items-center gap-3 p-3 rounded-lg hover:bg-gray-100 transition group">
          <div class="w-10 h-10 rounded-full flex items-center justify-center text-white text-sm font-bold flex-shrink-0"
               style="background-color: ${disciplinaColore}">
            ${paginaNumero}
          </div>
          <div class="flex-1 min-w-0">
            <div class="text-sm font-medium text-gray-800 truncate">${paginaTitolo}</div>
            <div class="text-xs text-gray-500">Pag. ${paginaNumero}</div>
          </div>
        </a>
      `
    }).join('')
  }

  saveState() {
    localStorage.setItem('sidebar-navigation-state', JSON.stringify(this.navigationState))
  }

  loadState() {
    const saved = localStorage.getItem('sidebar-navigation-state')
    if (saved) {
      try {
        this.navigationState = JSON.parse(saved)
      } catch (e) {
        console.error('Failed to parse saved navigation state', e)
      }
    }
  }
}
