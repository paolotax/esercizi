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
      volumeClasse: null,
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
      volumeClasse: null,
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
      volumeClasse: null,
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
    const volumeClasse = button.dataset.volumeClasse

    this.navigationState.level = 'discipline'
    this.navigationState.volumeId = volumeId
    this.navigationState.volumeNome = volumeNome
    this.navigationState.volumeClasse = volumeClasse
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
      volumeClasse: null,
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
    this.navigationState.volumeClasse = null
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

    const { level, corsoNome, volumeNome, volumeClasse, disciplinaNome } = this.navigationState

    let title = 'Libri di Testo'
    let subtitle = null

    if (level === 'volumi' && corsoNome) {
      title = corsoNome
    } else if (level === 'discipline' && volumeNome) {
      title = volumeNome
      subtitle = volumeClasse ? `Classe ${volumeClasse}` : null
    } else if (level === 'pagine' && disciplinaNome) {
      // Mostra titolo volume e sotto disciplina + classe
      title = volumeNome
      subtitle = disciplinaNome.toUpperCase() + (volumeClasse ? ` Classe ${volumeClasse}` : '')
    }

    if (subtitle) {
      this.titleTarget.innerHTML = `
        <span class="block text-sm">${title}</span>
        <span class="block text-xs font-medium text-gray-500 dark:text-gray-400">${subtitle}</span>
      `
    } else {
      this.titleTarget.textContent = title
    }
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

    // Colori pastello per i corsi
    const corsoColors = [
      { bg: 'from-pastel-sky/30 to-pastel-aqua/30', border: 'border-pastel-sky', icon: 'bg-gradient-to-br from-pastel-sky to-pastel-aqua', text: 'text-cyan-700 dark:text-cyan-300' },
      { bg: 'from-pastel-pink/30 to-pastel-coral/30', border: 'border-pastel-pink', icon: 'bg-gradient-to-br from-pastel-pink to-pastel-coral', text: 'text-pink-700 dark:text-pink-300' },
      { bg: 'from-pastel-mint/30 to-pastel-aqua/30', border: 'border-pastel-mint', icon: 'bg-gradient-to-br from-pastel-mint to-pastel-aqua', text: 'text-emerald-700 dark:text-emerald-300' },
      { bg: 'from-pastel-peach/30 to-pastel-lemon/30', border: 'border-pastel-peach', icon: 'bg-gradient-to-br from-pastel-peach to-pastel-lemon', text: 'text-orange-700 dark:text-orange-300' },
      { bg: 'from-pastel-lavender/30 to-pastel-lilac/30', border: 'border-pastel-lavender', icon: 'bg-gradient-to-br from-pastel-lavender to-pastel-lilac', text: 'text-purple-700 dark:text-purple-300' },
    ]

    return corsi.map((corso, index) => {
      const corsoId = corso.dataset.corsoId
      const corsoNome = corso.dataset.corsoNome
      const volumiCount = corso.querySelectorAll('[data-volume-id]').length
      const colors = corsoColors[index % corsoColors.length]

      return `
        <button class="flex flex-col items-center justify-center gap-2 p-4 rounded-2xl bg-gradient-to-br ${colors.bg} dark:from-gray-800/50 dark:to-gray-700/50 hover:scale-105 hover:shadow-lg transition-all duration-200 text-center border-2 ${colors.border} dark:border-gray-600"
                data-action="click->sidebar-breadcrumb#selectCorso"
                data-corso-id="${corsoId}"
                data-corso-nome="${corsoNome}">
          <div class="w-12 h-12 ${colors.icon} rounded-2xl flex items-center justify-center shadow-md">
            <svg class="w-7 h-7 text-white" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/>
            </svg>
          </div>
          <div class="font-bold ${colors.text} dark:text-gray-100 text-sm leading-tight">${corsoNome}</div>
          <div class="text-xs text-gray-500 dark:text-gray-400">${volumiCount} ${volumiCount === 1 ? 'volume' : 'volumi'}</div>
        </button>
      `
    }).join('')
  }

  renderVolumi(corsoId) {
    const corsoData = this.dataTarget.querySelector(`[data-corso-id="${corsoId}"]`)
    if (!corsoData) return ''

    const volumi = Array.from(corsoData.querySelectorAll('[data-volume-id]'))

    // Colori pastello per i volumi (basati sulla classe)
    const volumeColors = [
      { bg: 'from-pastel-lemon/40 to-pastel-peach/40', border: 'border-pastel-lemon', icon: 'bg-gradient-to-br from-yellow-400 to-orange-400', badge: 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900/50 dark:text-yellow-300' },
      { bg: 'from-pastel-mint/40 to-pastel-aqua/40', border: 'border-pastel-mint', icon: 'bg-gradient-to-br from-emerald-400 to-cyan-400', badge: 'bg-emerald-100 text-emerald-700 dark:bg-emerald-900/50 dark:text-emerald-300' },
      { bg: 'from-pastel-sky/40 to-pastel-lavender/40', border: 'border-pastel-sky', icon: 'bg-gradient-to-br from-sky-400 to-indigo-400', badge: 'bg-sky-100 text-sky-700 dark:bg-sky-900/50 dark:text-sky-300' },
      { bg: 'from-pastel-pink/40 to-pastel-lilac/40', border: 'border-pastel-pink', icon: 'bg-gradient-to-br from-pink-400 to-purple-400', badge: 'bg-pink-100 text-pink-700 dark:bg-pink-900/50 dark:text-pink-300' },
      { bg: 'from-pastel-coral/40 to-pastel-peach/40', border: 'border-pastel-coral', icon: 'bg-gradient-to-br from-red-400 to-orange-400', badge: 'bg-red-100 text-red-700 dark:bg-red-900/50 dark:text-red-300' },
    ]

    return volumi.map((volume, index) => {
      const volumeId = volume.dataset.volumeId
      const volumeNome = volume.dataset.volumeNome
      const volumeClasse = volume.dataset.volumeClasse
      const disciplineCount = volume.querySelectorAll('[data-disciplina-id]').length
      const colors = volumeColors[index % volumeColors.length]

      return `
        <button class="flex flex-col items-center justify-center gap-2 p-4 rounded-2xl bg-gradient-to-br ${colors.bg} dark:from-gray-800/50 dark:to-gray-700/50 hover:scale-105 hover:shadow-lg transition-all duration-200 text-center border-2 ${colors.border} dark:border-gray-600"
                data-action="click->sidebar-breadcrumb#selectVolume"
                data-volume-id="${volumeId}"
                data-volume-nome="${volumeNome}"
                data-volume-classe="${volumeClasse || ''}">
          <div class="w-12 h-12 ${colors.icon} rounded-2xl flex items-center justify-center shadow-md">
            <svg class="w-7 h-7 text-white" fill="currentColor" viewBox="0 0 24 24">
              <path d="M6 2a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6H6zm0 2h7v5h5v11H6V4z"/>
            </svg>
          </div>
          <div class="font-bold text-gray-800 dark:text-gray-100 text-sm leading-tight">${volumeNome}</div>
          ${volumeClasse ? `<span class="text-xs font-semibold px-2 py-0.5 rounded-full ${colors.badge}">Classe ${volumeClasse}</span>` : ''}
          <div class="text-xs text-gray-500 dark:text-gray-400">${disciplineCount} ${disciplineCount === 1 ? 'disciplina' : 'discipline'}</div>
        </button>
      `
    }).join('')
  }

  renderDiscipline(volumeId) {
    const volumeData = this.dataTarget.querySelector(`[data-volume-id="${volumeId}"]`)
    if (!volumeData) return ''

    const discipline = Array.from(volumeData.querySelectorAll('[data-disciplina-id]'))

    // Icone per le discipline comuni
    const disciplinaIcons = {
      'matematica': '<path d="M7 2v11h3v9l7-12h-4l4-8z"/>',
      'italiano': '<path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-3.95-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93zm6.9-2.54c-.26-.81-1-1.39-1.9-1.39h-1v-3c0-.55-.45-1-1-1H8v-2h2c.55 0 1-.45 1-1V7h2c1.1 0 2-.9 2-2v-.41c2.93 1.19 5 4.06 5 7.41 0 2.08-.8 3.97-2.1 5.39z"/>',
      'scienze': '<path d="M19.8 18.4L14 10.67V6.5l1.35-1.69c.26-.33.03-.81-.39-.81H9.04c-.42 0-.65.48-.39.81L10 6.5v4.17L4.2 18.4c-.49.66-.02 1.6.8 1.6h14c.82 0 1.29-.94.8-1.6z"/>',
      'storia': '<path d="M13 3c-4.97 0-9 4.03-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42C8.27 19.99 10.51 21 13 21c4.97 0 9-4.03 9-9s-4.03-9-9-9zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z"/>',
      'geografia': '<path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-3.95-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93zm6.9-2.54c-.26-.81-1-1.39-1.9-1.39h-1v-3c0-.55-.45-1-1-1H8v-2h2c.55 0 1-.45 1-1V7h2c1.1 0 2-.9 2-2v-.41c2.93 1.19 5 4.06 5 7.41 0 2.08-.8 3.97-2.1 5.39z"/>',
      'grammatica': '<path d="M5 4v3h5.5v12h3V7H19V4H5z"/>',
      'default': '<path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-5 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/>'
    }

    return discipline.map(disciplina => {
      const disciplinaId = disciplina.dataset.disciplinaId
      const disciplinaNome = disciplina.dataset.disciplinaNome
      const disciplinaColore = disciplina.dataset.disciplinaColore || '#6366f1'
      const pagineCount = disciplina.querySelectorAll('[data-pagina-id]').length

      // Trova icona appropriata
      const nomeLower = disciplinaNome.toLowerCase()
      let iconPath = disciplinaIcons.default
      for (const [key, path] of Object.entries(disciplinaIcons)) {
        if (nomeLower.includes(key)) {
          iconPath = path
          break
        }
      }

      return `
        <button class="flex flex-col items-center justify-center gap-2 p-4 rounded-2xl bg-white/80 dark:bg-gray-800/50 hover:scale-105 hover:shadow-lg transition-all duration-200 text-center border-2"
                style="border-color: ${disciplinaColore}20; background: linear-gradient(135deg, ${disciplinaColore}15, ${disciplinaColore}05);"
                data-action="click->sidebar-breadcrumb#selectDisciplina"
                data-disciplina-id="${disciplinaId}"
                data-disciplina-nome="${disciplinaNome}">
          <div class="w-12 h-12 rounded-2xl flex items-center justify-center shadow-md"
               style="background: linear-gradient(135deg, ${disciplinaColore}, ${disciplinaColore}dd);">
            <svg class="w-7 h-7 text-white" fill="currentColor" viewBox="0 0 24 24">
              ${iconPath}
            </svg>
          </div>
          <div class="font-bold text-sm leading-tight" style="color: ${disciplinaColore}">${disciplinaNome}</div>
          <div class="text-xs text-gray-500 dark:text-gray-400">${pagineCount} ${pagineCount === 1 ? 'pagina' : 'pagine'}</div>
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

    const disciplinaColore = disciplinaData.dataset.disciplinaColore || '#6366f1'
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
        ? 'ring-2 ring-offset-2 dark:ring-offset-gray-800 scale-105 shadow-lg'
        : 'hover:scale-102 hover:shadow-md'

      return `
        <a href="${paginaPath}"
           data-turbo-frame="main-content"
           data-action="click->sidebar-breadcrumb#handlePaginaClick"
           class="flex flex-col items-center justify-center gap-1 p-3 rounded-2xl bg-white/80 dark:bg-gray-800/50 transition-all duration-200 text-center border-2 ${activeClasses}"
           style="border-color: ${badgeColor}30; ${isActive ? `--tw-ring-color: ${badgeColor};` : ''}">
          <div class="w-10 h-10 rounded-xl flex items-center justify-center text-white text-base font-bold shadow-md"
               style="background: linear-gradient(135deg, ${badgeColor}, ${badgeColor}dd);">
            ${paginaNumero}
          </div>
          <div class="text-xs ${isActive ? 'font-bold' : 'font-semibold'} text-gray-800 dark:text-gray-200 leading-tight line-clamp-2">${paginaTitolo}</div>
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
        const parsed = JSON.parse(saved)
        // Merge con lo stato di default per gestire nuove proprietà
        this.navigationState = {
          ...this.navigationState,
          ...parsed
        }
      } catch (e) {
        console.error('Failed to parse saved navigation state', e)
      }
    }
  }
}
