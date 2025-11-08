import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="exercise-group"
export default class extends Controller {
  static targets = ["option", "checkbox", "checkmark"]

  connect() {
    console.log("Exercise group controller connected")
  }

  toggleCheck(event) {
    const option = event.currentTarget
    const checkbox = option.querySelector("[data-exercise-group-target=\"checkbox\"]")
    const checkmark = option.querySelector("[data-exercise-group-target=\"checkmark\"]")
    const isCorrect = option.dataset.correct === "true"

    console.log("toggleCheck called", {
      checkbox: checkbox,
      checkmark: checkmark,
      text: checkbox ? checkbox.textContent.trim() : 'no checkbox'
    })

    // Get all options in this group to deselect others (single selection behavior)
    const group = option.closest("[data-controller=\"exercise-group\"]")
    const allOptions = group.querySelectorAll("[data-exercise-group-target=\"option\"]")

    // Check if this option is already selected
    const isCurrentlySelected = option.dataset.selected === "true"

    // Deselect all options in this group first
    allOptions.forEach(opt => {
      const cb = opt.querySelector("[data-exercise-group-target=\"checkbox\"]")
      const cm = opt.querySelector("[data-exercise-group-target=\"checkmark\"]")
      if (cm) cm.classList.add("hidden")
      cb.classList.remove("bg-gray-100", "bg-orange-300", "bg-pink-300", "bg-sky-300",
                          "bg-purple-300", "bg-green-300", "bg-green-200", "bg-gray-200", "bg-blue-300")
      cb.classList.add("bg-white") // Reset to white
      opt.dataset.selected = "false"
    })

    // If it wasn't selected, select it now
    if (!isCurrentlySelected) {
      if (checkmark) {
        // For pages with checkmark (pag010, pag010gen, pag043, pag051)
        checkmark.classList.remove("hidden")
        if (isCorrect) {
          checkbox.classList.add("bg-green-200")
        } else {
          checkbox.classList.add("bg-gray-200")
        }
      } else {
        // For pages without checkmark (pag050, pag022, pag167)
        // Color based on the letter or text content
        const text = checkbox.textContent.trim()

        // Map for single vowels (pag050)
        const vowelColorMap = {
          'A': 'bg-orange-300',
          'E': 'bg-pink-300',
          'I': 'bg-sky-300',
          'O': 'bg-purple-300',
          'U': 'bg-green-300'
        }

        // Map for text content (pag167)
        const textColorMap = {
          'SCIA': 'bg-orange-300',
          'SCIO': 'bg-purple-300',
          'SCIU': 'bg-green-300',
          'SCE': 'bg-pink-300',
          'SCI': 'bg-sky-300'
        }

        // Determine color: check vowels first, then text, then default to blue
        let bgColor = vowelColorMap[text] || textColorMap[text] || 'bg-blue-300'

        console.log("Adding color", {
          text: text,
          bgColor: bgColor,
          checkbox: checkbox
        })

        checkbox.classList.remove("bg-white") // Remove white background
        checkbox.classList.add(bgColor)
      }

      option.dataset.selected = "true"
    }
    // If it was already selected, it's now deselected (from the forEach loop above)
  }
}
