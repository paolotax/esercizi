import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="word-sorter"
export default class extends Controller {
  static targets = ["input", "word", "dropZone"]

  connect() {
    this.setupDragAndDrop()
  }

  setupDragAndDrop() {
    // Make words draggable
    this.wordTargets.forEach(word => {
      word.draggable = true
      word.addEventListener('dragstart', (e) => this.handleDragStart(e))
      word.addEventListener('dragend', (e) => this.handleDragEnd(e))
      word.classList.add('cursor-grab', 'active:cursor-grabbing')
    })

    // Setup drop zones (inputs)
    this.inputTargets.forEach(input => {
      input.addEventListener('dragover', (e) => this.handleDragOver(e))
      input.addEventListener('drop', (e) => this.handleDrop(e))
      input.addEventListener('dragenter', (e) => this.handleDragEnter(e))
      input.addEventListener('dragleave', (e) => this.handleDragLeave(e))
    })
  }

  handleDragStart(event) {
    const word = event.target.textContent.trim().replace(/^•\s*/, '')
    event.dataTransfer.setData('text/plain', word)
    event.dataTransfer.effectAllowed = 'move'
    event.target.classList.add('opacity-50')
    this.draggedWord = event.target
  }

  handleDragEnd(event) {
    // Remove opacity from dragged word
    event.target.classList.remove('opacity-50')
    this.draggedWord = null
  }

  handleDragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = 'move'
  }

  handleDragEnter(event) {
    event.preventDefault()
    event.currentTarget.classList.add('bg-blue-50', 'border-blue-400')
  }

  handleDragLeave(event) {
    // Only remove if we're actually leaving (not entering a child)
    if (!event.currentTarget.contains(event.relatedTarget)) {
      event.currentTarget.classList.remove('bg-blue-50', 'border-blue-400')
    }
  }

  handleDrop(event) {
    event.preventDefault()
    event.currentTarget.classList.remove('bg-blue-50', 'border-blue-400')
    
    const word = event.dataTransfer.getData('text/plain')
    event.currentTarget.value = word
    
    // Mark the dragged word as used with a cross
    if (this.draggedWord) {
      this.draggedWord.classList.remove('opacity-50')
      
      // Check if word is already marked (avoid duplicates)
      if (!this.draggedWord.querySelector('.used-cross')) {
        const cross = document.createElement('span')
        cross.className = 'used-cross text-red-600 font-bold ml-2'
        cross.textContent = '✗'
        this.draggedWord.appendChild(cross)
        
        // Make word look used (grayed out)
        this.draggedWord.classList.add('opacity-60', 'line-through')
        this.draggedWord.draggable = false
      }
      
      this.draggedWord = null
    }

    // Add visual feedback
    event.currentTarget.classList.add('border-green-400')
    setTimeout(() => {
      event.currentTarget.classList.remove('border-green-400')
    }, 300)
  }

  checkAnswers(event) {
    event.preventDefault()

    let allCorrect = true
    let correctCount = 0
    let incorrectCount = 0
    let emptyCount = 0

    this.inputTargets.forEach(input => {
      const correctAnswer = input.dataset.correctAnswer.trim().toLowerCase()
      const userAnswer = input.value.trim().toLowerCase()

      // Remove previous styling
      input.classList.remove("border-green-500", "border-red-500", "border-yellow-500",
                            "bg-green-50", "bg-red-50", "bg-yellow-50")

      if (userAnswer === "") {
        emptyCount++
        allCorrect = false
        input.classList.add("border-yellow-500", "bg-yellow-50")
      } else if (userAnswer === correctAnswer) {
        correctCount++
        input.classList.add("border-green-500", "bg-green-50")
      } else {
        incorrectCount++
        allCorrect = false
        input.classList.add("border-red-500", "bg-red-50")

        // Shake animation
        input.classList.add("animate-shake")
        setTimeout(() => input.classList.remove("animate-shake"), 500)
      }
    })

    this.showFeedback(allCorrect, correctCount, incorrectCount, emptyCount)
  }

  showFeedback(allCorrect, correctCount, incorrectCount, emptyCount) {
    const existingFeedback = this.element.querySelector(".word-sorter-feedback")
    if (existingFeedback) {
      existingFeedback.remove()
    }

    const feedbackDiv = document.createElement("div")
    feedbackDiv.className = "word-sorter-feedback mt-6 p-6 rounded-lg shadow-lg " +
                            (allCorrect ? "bg-green-100 border-4 border-green-500" : "bg-orange-100 border-4 border-orange-500")

    const title = document.createElement("h2")
    title.className = "text-2xl font-bold mb-4 " + (allCorrect ? "text-green-800" : "text-orange-800")
    title.textContent = allCorrect ? "🎉 Eccellente! Tutte le risposte sono corrette!" : "📝 Controlla le risposte evidenziate"

    const stats = document.createElement("div")
    stats.className = "text-lg space-y-2"
    stats.innerHTML = `
      ${correctCount > 0 ? `<p class="text-green-700">✅ Corrette: ${correctCount}</p>` : ''}
      ${incorrectCount > 0 ? `<p class="text-red-700">❌ Errate: ${incorrectCount}</p>` : ''}
      ${emptyCount > 0 ? `<p class="text-yellow-700">⚠️ Da completare: ${emptyCount}</p>` : ''}
    `

    feedbackDiv.appendChild(title)
    feedbackDiv.appendChild(stats)

    if (!allCorrect) {
      const retryButton = document.createElement("button")
      retryButton.className = "mt-4 bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-6 rounded-full transition"
      retryButton.textContent = "🔄 Riprova"
      retryButton.onclick = () => this.reset()
      feedbackDiv.appendChild(retryButton)
    }

    this.element.appendChild(feedbackDiv)
    feedbackDiv.scrollIntoView({ behavior: "smooth", block: "center" })
  }

  reset() {
    this.inputTargets.forEach(input => {
      input.value = ""
      input.classList.remove("border-green-500", "border-red-500", "border-yellow-500",
                            "bg-green-50", "bg-red-50", "bg-yellow-50", "border-green-400",
                            "bg-blue-50", "border-blue-400")
    })

    // Reset word state: remove opacity, cross, line-through, and re-enable dragging
    this.wordTargets.forEach(word => {
      word.classList.remove("opacity-50", "opacity-60", "line-through")
      word.draggable = true
      
      // Remove cross if present
      const cross = word.querySelector('.used-cross')
      if (cross) {
        cross.remove()
      }
    })

    const feedback = this.element.querySelector(".word-sorter-feedback")
    if (feedback) feedback.remove()
  }
}
