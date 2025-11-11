import { Controller } from "@hotwired/stimulus"

// Controller for interactive word highlighting exercises with toggle functionality
// Allows users to click words to toggle highlighting in different colors
export default class extends Controller {
  static targets = ["colorBox", "word"]
  static values = {
    selectedColor: { type: String, default: "" },
    multiColor: { type: Boolean, default: false } // If true, requires color selection
  }

  connect() {
    console.log("Word highlighter controller connected")
    console.log("Multi-color mode:", this.multiColorValue)
    this.selectedColorValue = ""
  }

  // Get color from element's classes
  getColorFromElement(element) {
    if (element.classList.contains('bg-red-300')) return 'red'
    if (element.classList.contains('bg-blue-300')) return 'blue'
    if (element.classList.contains('bg-green-300')) return 'green'
    if (element.classList.contains('bg-yellow-300')) return 'yellow'
    if (element.classList.contains('bg-purple-300')) return 'purple'
    if (element.classList.contains('bg-pink-300')) return 'pink'
    if (element.classList.contains('bg-orange-300')) return 'orange'
    if (element.classList.contains('bg-cyan-300')) return 'cyan'
    if (element.classList.contains('bg-teal-300')) return 'teal'
    if (element.classList.contains('bg-indigo-300')) return 'indigo'
    if (element.classList.contains('bg-violet-300')) return 'violet'
    if (element.classList.contains('bg-lime-300')) return 'lime'
    return null
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

  // Toggle highlighting with color on click
  toggleHighlight(event) {
    const wordElement = event.currentTarget

    // If multi-color mode, check if a color is selected
    if (this.multiColorValue && !this.selectedColorValue) {
      alert("Prima seleziona un colore!")
      return
    }

    // Get current color of the word
    const currentColor = this.getColorFromElement(wordElement)

    // Determine target color
    let targetColor = this.selectedColorValue || 'red'

    // If has color boxes but not multi-color mode, use first color
    if (this.hasColorBoxTarget && !this.multiColorValue) {
      const firstColorBox = this.colorBoxTargets[0]
      if (firstColorBox) {
        targetColor = firstColorBox.dataset.color
      }
    }

    // Remove all previous color classes
    this.removeAllColors(wordElement)

    // Toggle: if already has the target color, remove it (unhighlight)
    if (currentColor === targetColor) {
      // Remove highlighting - word returns to default state
      console.log(`Rimossa evidenziatura da "${wordElement.textContent.trim()}"`)
    } else {
      // Add new color
      const colorClasses = this.getColorClasses(targetColor)
      wordElement.classList.add(...colorClasses)

      // Visual feedback
      wordElement.classList.add('animate-pulse')
      setTimeout(() => {
        wordElement.classList.remove('animate-pulse')
      }, 300)

      console.log(`Evidenziata "${wordElement.textContent.trim()}" con ${targetColor}`)
    }
  }

  // Legacy method for compatibility - now just calls toggleHighlight
  highlightWord(event) {
    this.toggleHighlight(event)
  }

  removeAllColors(element) {
    element.classList.remove(
      'bg-red-300', 'bg-blue-300', 'bg-green-300', 'bg-yellow-300',
      'bg-purple-300', 'bg-pink-300', 'bg-orange-300', 'bg-cyan-300',
      'bg-teal-300', 'bg-indigo-300', 'bg-violet-300', 'bg-lime-300',
      'text-red-900', 'text-blue-900', 'text-green-900', 'text-yellow-900',
      'text-purple-900', 'text-pink-900', 'text-orange-900', 'text-cyan-900',
      'text-teal-900', 'text-indigo-900', 'text-violet-900', 'text-lime-900',
      'font-bold', 'px-1', 'rounded', 'ring-2', 'ring-green-500', 'ring-red-500', 'ring-offset-1'
    )
  }

  getColorClasses(color) {
    const colorMap = {
      'red': ['bg-red-300', 'text-red-900', 'font-bold', 'px-1', 'rounded'],
      'blue': ['bg-blue-300', 'text-blue-900', 'font-bold', 'px-1', 'rounded'],
      'green': ['bg-green-300', 'text-green-900', 'font-bold', 'px-1', 'rounded'],
      'yellow': ['bg-yellow-300', 'text-yellow-900', 'font-bold', 'px-1', 'rounded'],
      'purple': ['bg-purple-300', 'text-purple-900', 'font-bold', 'px-1', 'rounded'],
      'pink': ['bg-pink-300', 'text-pink-900', 'font-bold', 'px-1', 'rounded'],
      'orange': ['bg-orange-300', 'text-orange-900', 'font-bold', 'px-1', 'rounded'],
      'cyan': ['bg-cyan-300', 'text-cyan-900', 'font-bold', 'px-1', 'rounded'],
      'teal': ['bg-teal-300', 'text-teal-900', 'font-bold', 'px-1', 'rounded'],
      'indigo': ['bg-indigo-300', 'text-indigo-900', 'font-bold', 'px-1', 'rounded'],
      'violet': ['bg-violet-300', 'text-violet-900', 'font-bold', 'px-1', 'rounded'],
      'lime': ['bg-lime-300', 'text-lime-900', 'font-bold', 'px-1', 'rounded']
    }

    return colorMap[color] || []
  }

  clearHighlights() {
    // Clear all highlighted words
    this.wordTargets.forEach(word => {
      this.removeAllColors(word)
    })

    // Clear color selection if in multi-color mode
    if (this.hasColorBoxTarget) {
      this.colorBoxTargets.forEach(box => {
        box.classList.remove('ring-4', 'ring-offset-2', 'ring-gray-800', 'scale-110', 'shadow-lg')
        box.classList.add('ring-2', 'ring-gray-300')
      })
      this.selectedColorValue = ""
    }

    console.log("Evidenziature cancellate")
  }

  showSolution() {
    // Highlight all words that should be highlighted according to data-correct attribute
    this.wordTargets.forEach(word => {
      const correctValue = word.dataset.correct

      this.removeAllColors(word)

      // Handle true/false values for monocolor mode
      if (correctValue === "true") {
        // Use the selected color or first available color
        let targetColor = this.selectedColorValue || 'red'
        if (this.hasColorBoxTarget && !this.multiColorValue) {
          const firstColorBox = this.colorBoxTargets[0]
          if (firstColorBox) {
            targetColor = firstColorBox.dataset.color
          }
        }
        const colorClasses = this.getColorClasses(targetColor)
        word.classList.add(...colorClasses)
      } else if (correctValue === "false") {
        // Don't highlight - this is correct as not highlighted
        // Do nothing
      } else if (correctValue) {
        // Legacy: correctValue is a color name
        const colorClasses = this.getColorClasses(correctValue)
        word.classList.add(...colorClasses)
      }
    })

    console.log("Soluzione mostrata")
  }

  checkAnswers(event) {
    if (event) {
      event.preventDefault()
    }

    let correctCount = 0
    let incorrectCount = 0
    let missedCount = 0
    let extraCount = 0

    // Check each word
    this.wordTargets.forEach(word => {
      const correctValue = word.dataset.correct
      const currentColor = this.getColorFromElement(word)

      // Remove previous feedback
      word.classList.remove('ring-2', 'ring-green-500', 'ring-red-500', 'ring-offset-1')

      // Handle true/false values for monocolor mode
      if (correctValue === "true") {
        // This word should be highlighted (any color is ok)
        if (currentColor !== null) {
          // Correct - it's highlighted
          word.classList.add('ring-2', 'ring-green-500', 'ring-offset-1')
          correctCount++
        } else {
          // Missed - should be highlighted but isn't
          word.classList.add('ring-2', 'ring-red-500', 'ring-offset-1')
          missedCount++
        }
      } else if (correctValue === "false") {
        // This word should NOT be highlighted
        if (currentColor === null) {
          // Correct - it's not highlighted
          correctCount++
        } else {
          // Incorrectly highlighted
          word.classList.add('ring-2', 'ring-red-500', 'ring-offset-1')
          extraCount++
          incorrectCount++
        }
      } else if (correctValue) {
        // Legacy: correctValue is a color name (multicolor mode)
        if (currentColor === correctValue) {
          // Correct color!
          word.classList.add('ring-2', 'ring-green-500', 'ring-offset-1')
          correctCount++
        } else if (currentColor === null) {
          // Missed - should be highlighted but isn't
          word.classList.add('ring-2', 'ring-red-500', 'ring-offset-1')
          missedCount++
        } else {
          // Wrong color
          word.classList.add('ring-2', 'ring-red-500', 'ring-offset-1')
          incorrectCount++
        }
      } else {
        // No data-correct attribute - this word should NOT be highlighted
        if (currentColor !== null) {
          // Incorrectly highlighted
          word.classList.add('ring-2', 'ring-red-500', 'ring-offset-1')
          extraCount++
          incorrectCount++
        } else {
          // Correctly not highlighted
          correctCount++
        }
      }
    })

    // Calculate total words that should be highlighted
    const totalToHighlight = this.wordTargets.filter(w =>
      w.dataset.correct === "true" || (w.dataset.correct && w.dataset.correct !== "false")
    ).length
    const totalWords = this.wordTargets.length

    // Show feedback
    let message = ""
    if (correctCount === totalWords && missedCount === 0 && incorrectCount === 0) {
      message = `✅ Perfetto! Tutte le risposte sono corrette! (${totalToHighlight}/${totalToHighlight})`
    } else {
      message = `Risultati:\n✅ Corrette: ${correctCount}/${totalWords}`
      if (incorrectCount > 0) {
        message += `\n❌ Errate: ${incorrectCount}`
      }
      if (missedCount > 0) {
        message += `\n⚠️ Mancanti: ${missedCount}`
      }
    }

    alert(message)

    return { correctCount, incorrectCount, missedCount, extraCount, totalWords, totalToHighlight }
  }
}
