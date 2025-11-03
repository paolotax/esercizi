import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="error-finder"
export default class extends Controller {
  static targets = ["word", "hint"]

  connect() {
    // All words start unselected
    this.wordTargets.forEach(word => {
      word.classList.add("cursor-pointer", "transition", "hover:bg-gray-100")
    })
  }

  selectWord(event) {
    const clickedWord = event.currentTarget
    const isError = clickedWord.dataset.error === "true"
    const group = clickedWord.closest(".error-group")
    
    if (!group) return

    // Remove all highlights from words in this group
    const wordsInGroup = group.querySelectorAll("[data-error-finder-target='word']")
    wordsInGroup.forEach(word => {
      word.classList.remove("bg-red-200", "border-2", "border-red-500", "rounded-lg")
      word.classList.remove("bg-green-200", "border-2", "border-green-500", "rounded-lg")
    })

    // Highlight the clicked word
    if (isError) {
      clickedWord.classList.add("bg-red-200", "border-2", "border-red-500", "rounded-lg")
    } else {
      clickedWord.classList.add("bg-green-200", "border-2", "border-green-500", "rounded-lg")
    }

    // Show/hide hint for this group
    const hint = group.querySelector("[data-error-finder-target='hint']")
    if (hint) {
      if (isError) {
        hint.classList.remove("hidden")
      } else {
        hint.classList.add("hidden")
      }
    }
  }

  reset() {
    this.wordTargets.forEach(word => {
      word.classList.remove("bg-red-200", "border-2", "border-red-500", "rounded-lg")
      word.classList.remove("bg-green-200", "border-2", "border-green-500", "rounded-lg")
    })
    
    this.hintTargets.forEach(hint => {
      hint.classList.add("hidden")
    })
  }
}

