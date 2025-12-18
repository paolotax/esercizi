import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {

    // Ascolta eventi globali per aprire il pannello
    document.addEventListener('open-properties', this.handleOpenEvent.bind(this))
  }

  disconnect() {
    document.removeEventListener('open-properties', this.handleOpenEvent.bind(this))
  }

  handleOpenEvent(event) {
    const { operationId, operationType } = event.detail
    this.open(operationId, operationType)
  }

  open(operationId, operationType) {
    // Mostra il pannello
    const panel = document.getElementById('properties-panel')
    const overlay = document.getElementById('properties-overlay')

    panel.classList.remove('translate-x-full')
    overlay.classList.remove('hidden')

    // Carica il form appropriato via Turbo
    this.loadOperationForm(operationId, operationType)
  }

  close() {
    const panel = document.getElementById('properties-panel')
    const overlay = document.getElementById('properties-overlay')

    panel.classList.add('translate-x-full')
    overlay.classList.add('hidden')
  }

  async loadOperationForm(operationId, operationType) {
    const esercizioId = document.querySelector('[data-esercizio-id]').dataset.esercizioId
    const url = `/dashboard/esercizi/${esercizioId}/operation_properties?operation_id=${operationId}&operation_type=${operationType}`

    try {
      const response = await fetch(url, {
        headers: {
          'Accept': 'text/html',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })

      if (response.ok) {
        const html = await response.text()
        // Trova il turbo-frame nel pannello e aggiorna il contenuto
        const frameContainer = document.querySelector('#properties-panel turbo-frame') ||
                              document.querySelector('#properties-panel [data-controller="properties-panel"] > div:last-child')

        if (frameContainer) {
          frameContainer.innerHTML = html
        }
      } else {
        console.error('Errore risposta:', response.status)
      }
    } catch (error) {
      console.error('Errore nel caricamento del form:', error)
    }
  }
}