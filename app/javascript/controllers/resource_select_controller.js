import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["resourceSelect", "corso", "volume", "disciplina", "pagina"]

  typeChanged(event) {
    const type = event.target.value.toLowerCase()
    const select = this.resourceSelectTarget

    select.innerHTML = '<option value="">Seleziona...</option>'

    if (!type) return

    const dataTarget = this[`${type}Target`]
    if (!dataTarget) return

    try {
      const items = JSON.parse(dataTarget.textContent)
      items.forEach(item => {
        const option = document.createElement('option')
        option.value = item.id
        option.textContent = item.name
        select.appendChild(option)
      })
    } catch (e) {
      console.error('Error parsing resource data:', e)
    }
  }
}
