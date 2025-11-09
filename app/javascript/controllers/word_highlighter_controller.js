import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="word-highlighter"
export default class extends Controller {
  static targets = ["colorBox", "word"]
  static values = {
    selectedColor: { type: String, default: "" }
  }

  connect() {
    console.log("Word highlighter controller connected")
    this.selectedColorValue = ""
  }

  selectColor(event) {
    const colorBox = event.currentTarget
    const color = colorBox.dataset.color

    // Remove selection from all color boxes
    this.colorBoxTargets.forEach(box => {
      box.classList.remove('ring-4', 'ring-offset-2', 'ring-gray-800', 'scale-110', 'shadow-lg')
      box.classList.add('ring-2', 'ring-gray-300')
    })

    // Add selection to clicked box
    colorBox.classList.add('ring-4', 'ring-offset-2', 'ring-gray-800', 'scale-110', 'shadow-lg')
    colorBox.classList.remove('ring-2', 'ring-gray-300')

    this.selectedColorValue = color

    console.log("Selected color:", color)
  }

  highlightWord(event) {
    if (!this.selectedColorValue) {
      // No color selected, show hint
      alert("Prima seleziona un colore!")
      return
    }

    const wordElement = event.currentTarget

    // Remove all previous color classes from this word
    wordElement.classList.remove(
      'bg-red-200', 'bg-blue-200', 'bg-green-200', 'bg-yellow-200',
      'text-red-900', 'text-blue-900', 'text-green-900', 'text-yellow-900',
      'font-bold', 'px-1', 'rounded', 'animate-pulse'
    )

    // Add new color based on selection
    const colorClasses = this.getColorClasses(this.selectedColorValue)
    wordElement.classList.add(...colorClasses)

    // Visual feedback
    wordElement.classList.add('animate-pulse')
    setTimeout(() => {
      wordElement.classList.remove('animate-pulse')
    }, 300)

    console.log(`Parola "${wordElement.textContent.trim()}" colorata con ${this.selectedColorValue}`)
  }

  getColorClasses(color) {
    const colorMap = {
      'red': ['bg-red-200', 'text-red-900', 'font-bold', 'px-1', 'rounded'],
      'blue': ['bg-blue-200', 'text-blue-900', 'font-bold', 'px-1', 'rounded'],
      'green': ['bg-green-200', 'text-green-900', 'font-bold', 'px-1', 'rounded'],
      'yellow': ['bg-yellow-200', 'text-yellow-900', 'font-bold', 'px-1', 'rounded']
    }

    return colorMap[color] || []
  }

  getColorFromElement(element) {
    if (element.classList.contains('bg-red-200')) return 'red'
    if (element.classList.contains('bg-blue-200')) return 'blue'
    if (element.classList.contains('bg-green-200')) return 'green'
    if (element.classList.contains('bg-yellow-200')) return 'yellow'
    return null
  }

  clearHighlights() {
    // Find all words
    this.wordTargets.forEach(word => {
      word.classList.remove(
        'bg-red-200', 'bg-blue-200', 'bg-green-200', 'bg-yellow-200',
        'text-red-900', 'text-blue-900', 'text-green-900', 'text-yellow-900',
        'font-bold', 'px-1', 'rounded', 'animate-pulse'
      )
    })

    // Also clear color selection
    this.colorBoxTargets.forEach(box => {
      box.classList.remove('ring-4', 'ring-offset-2', 'ring-gray-800', 'scale-110', 'shadow-lg')
      box.classList.add('ring-2', 'ring-gray-300')
    })
    this.selectedColorValue = ""
  }
}
