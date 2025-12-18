import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="word-selector"
export default class extends Controller {
  static targets = ["word"]

  connect() {
  }

  selectWord(event) {
    const word = event.currentTarget
    const isCorrect = word.dataset.correct === "true"

    // Get the parent container to find sibling words
    const container = word.closest('[data-word-selector-container]')
    const allWords = container.querySelectorAll('[data-word-selector-target="word"]')

    // Reset all words in this container
    allWords.forEach(w => {
      w.classList.remove('bg-green-200', 'bg-red-200', 'font-bold')
      w.classList.add('cursor-pointer', 'hover:bg-gray-100')
    })

    // Highlight selected word
    if (isCorrect) {
      word.classList.add('bg-green-200', 'font-bold')
    } else {
      word.classList.add('bg-red-200', 'font-bold')
    }
    word.classList.remove('hover:bg-gray-100')
  }
}
