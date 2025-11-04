import { Controller } from "@hotwired/stimulus"

// Controller to show/hide buttons based on whether other controllers exist on the page
export default class extends Controller {
  connect() {
    // Check all buttons with data-controller-check attribute
    const buttons = document.querySelectorAll('[data-controller-check]')
    
    buttons.forEach(button => {
      const requiredController = button.dataset.controllerCheck
      
      // Check if an element with this controller exists on the page
      const controllerExists = document.querySelector(`[data-controller*="${requiredController}"]`)
      
      if (controllerExists) {
        // Show the button
        button.classList.remove('hidden')
      } else {
        // Keep it hidden
        button.classList.add('hidden')
      }
    })
  }
}

