import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="word-choice"
export default class extends Controller {
  static targets = ["word"]

  connect() {
    console.log("Word choice controller connected")
  }

  select(event) {
    const clickedWord = event.currentTarget
    const group = clickedWord.dataset.group

    // Find all words in the same group
    const groupWords = this.wordTargets.filter(w => w.dataset.group === group)

    // Reset all words in this group
    groupWords.forEach(word => {
      word.classList.remove('bg-pink-200', 'font-bold', 'underline', 'line-through', 'opacity-40', 'text-gray-500')
      word.classList.add('cursor-pointer', 'hover:bg-pink-100')
    })

    // Select the clicked word
    clickedWord.classList.remove('hover:bg-pink-100', 'line-through', 'opacity-40', 'text-gray-500')
    clickedWord.classList.add('bg-pink-200', 'font-bold', 'underline')

    // Strike through the other word(s) in the group
    groupWords.forEach(word => {
      if (word !== clickedWord) {
        word.classList.remove('bg-pink-200', 'font-bold', 'underline', 'hover:bg-pink-100')
        word.classList.add('line-through', 'opacity-40', 'text-gray-500', 'cursor-not-allowed')
      }
    })
  }
}
