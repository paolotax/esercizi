import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="copy-to-clipboard"
export default class extends Controller {
  static values = { content: String }
  static classes = [ "success" ] 
  
  async copy(event) {
    event.preventDefault()
    this.reset()

    try {
      await navigator.clipboard.writeText(this.contentValue)
      this.element.classList.add(this.successClass)
    } catch {}
  } 

  reset() {
    this.element.classList.remove(this.successClass)
    this.#forceReflow()
  }

  #forceReflow() {
    this.element.offsetWidth
  }  
}
