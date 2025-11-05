import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="fraction-circles"
export default class extends Controller {
  static targets = ["slice"]

  connect() {
    console.log("Fraction circles controller connected")
  }

  toggleSlice(event) {
    const slice = event.currentTarget
    const currentFill = slice.getAttribute('fill')

    if (currentFill === 'white' || currentFill === '#ffffff') {
      slice.setAttribute('fill', '#93C5FD') // blue-300
    } else {
      slice.setAttribute('fill', 'white')
    }
  }

  reset() {
    this.sliceTargets.forEach(slice => {
      slice.setAttribute('fill', 'white')
    })
  }
}
