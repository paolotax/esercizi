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

    // Ripristina scroll se c'è un valore salvato
    const savedScroll = sessionStorage.getItem('sidebar-scroll-temp')
    if (savedScroll !== null && this.sidebar) {
      // Usa requestAnimationFrame per assicurarsi che il rendering sia completo
      requestAnimationFrame(() => {
        this.sidebar.scrollTop = parseInt(savedScroll, 10)
        // Rimuovi il valore dopo averlo usato
        sessionStorage.removeItem('sidebar-scroll-temp')
      })
    }
  }

  disconnect() {
    // Cleanup se necessario
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
        <button class="w-full flex items-center justify-between gap-2 p-3 rounded-lg bg-gradient-to-r from-purple-50 to-pink-50 hover:from-purple-100 hover:to-pink-100 dark:from-purple-900/30 dark:to-pink-900/30 dark:hover:from-purple-800/40 dark:hover:to-pink-800/40 transition text-left group border border-purple-200 dark:border-purple-700"
                data-action="click->sidebar-breadcrumb#selectCorso"
                data-corso-id="${corsoId}"
                data-corso-nome="${corsoNome}">
          <div class="flex-1">
            <div class="font-bold text-gray-900 dark:text-gray-100">${corsoNome}</div>
            <div class="text-xs text-gray-600 dark:text-gray-400">${volumiCount} ${volumiCount === 1 ? 'volume' : 'volumi'}</div>
          </div>
          <svg class="w-5 h-5 text-purple-600 dark:text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
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
        <button class="w-full flex items-center justify-between gap-2 p-3 rounded-lg bg-gradient-to-r from-indigo-50 to-blue-50 hover:from-indigo-100 hover:to-blue-100 dark:from-indigo-900/30 dark:to-blue-900/30 dark:hover:from-indigo-800/40 dark:hover:to-blue-800/40 transition text-left group border border-indigo-200 dark:border-indigo-700"
                data-action="click->sidebar-breadcrumb#selectVolume"
                data-volume-id="${volumeId}"
                data-volume-nome="${volumeNome}">
          <div class="flex-1">
            <div class="font-semibold text-gray-900 dark:text-gray-100">${volumeNome}</div>
            ${volumeClasse ? `<div class="text-xs text-gray-600 dark:text-gray-400">Classe ${volumeClasse}</div>` : ''}
            <div class="text-xs text-gray-500 dark:text-gray-400">${disciplineCount} ${disciplineCount === 1 ? 'disciplina' : 'discipline'}</div>
          </div>
          <svg class="w-5 h-5 text-indigo-600 dark:text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
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
        <button class="w-full flex items-center justify-between gap-2 p-3 rounded-lg hover:bg-blue-50 dark:hover:bg-blue-900/30 transition text-left group border-l-4"
                style="border-color: ${disciplinaColore}"
                data-action="click->sidebar-breadcrumb#selectDisciplina"
                data-disciplina-id="${disciplinaId}"
                data-disciplina-nome="${disciplinaNome}">
          <div class="flex-1">
            <div class="font-semibold" style="color: ${disciplinaColore}">${disciplinaNome}</div>
            <div class="text-xs text-gray-500 dark:text-gray-400">${pagineCount} ${pagineCount === 1 ? 'pagina' : 'pagine'}</div>
          </div>
          <svg class="w-5 h-5 text-gray-600 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
          </svg>
        </button>
      `
    }).join('')
  }

  handlePaginaClick(event) {
    // Salva la posizione di scroll corrente
    if (this.sidebar) {
      const scrollTop = this.sidebar.scrollTop
      // Salva temporaneamente la posizione
      sessionStorage.setItem('sidebar-scroll-temp', scrollTop)
    }
  }

  renderPagine(disciplinaId) {
    const disciplinaData = this.dataTarget.querySelector(`[data-disciplina-id="${disciplinaId}"]`)
    if (!disciplinaData) return ''

    const disciplinaColore = disciplinaData.dataset.disciplinaColore
    const pagine = Array.from(disciplinaData.querySelectorAll('[data-pagina-id]'))

    // Ottieni l'URL corrente per evidenziare la pagina attiva
    const currentPath = window.location.pathname

    // Mappa colori per Tailwind
    const colorMap = {
      'purple': '#9333EA',
      'blue': '#2563EB',
      'cyan': '#0891B2',
      'green': '#16A34A',
      'orange': '#EA580C',
      'red': '#DC2626',
      'pink': '#DB2777',
      'amber': '#D97706',
      'indigo': '#4F46E5',
      'lime': '#65A30D'
    }

    return pagine.map(pagina => {
      const paginaNumero = pagina.dataset.paginaNumero
      const paginaTitolo = pagina.dataset.paginaTitolo
      const paginaSlug = pagina.dataset.paginaSlug
      const paginaSottotitolo = pagina.dataset.paginaSottotitolo
      const paginaBaseColor = pagina.dataset.paginaBaseColor
      const paginaPath = `/pagine/${paginaSlug}`

      // Usa base_color della pagina se disponibile, altrimenti colore disciplina
      const badgeColor = paginaBaseColor ? (colorMap[paginaBaseColor] || disciplinaColore) : disciplinaColore

      // Verifica se questa è la pagina corrente
      const isActive = currentPath === paginaPath
      const activeClasses = isActive
        ? 'bg-gray-100 dark:bg-gray-700 ring-2 ring-offset-2 dark:ring-offset-gray-800'
        : 'hover:bg-gray-100 dark:hover:bg-gray-700'

      return `
        <a href="${paginaPath}"
           data-turbo-frame="_top"
           data-action="click->sidebar-breadcrumb#handlePaginaClick"
           class="flex items-center gap-3 p-3 rounded-lg transition group ${activeClasses}"
           style="${isActive ? `--tw-ring-color: ${badgeColor};` : ''}">
          <div class="w-10 h-10 rounded-full flex items-center justify-center text-white text-sm font-bold flex-shrink-0"
               style="background-color: ${badgeColor}">
            ${paginaNumero}
          </div>
          <div class="flex-1 min-w-0">
            <div class="text-sm ${isActive ? 'font-bold' : 'font-medium'} text-gray-800 dark:text-gray-200 truncate">${paginaTitolo}</div>
            <div class="text-xs text-gray-500 dark:text-gray-400">${paginaSottotitolo || 'Pag. ' + paginaNumero}</div>
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
