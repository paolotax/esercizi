import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="fill-blanks"
export default class extends Controller {
  static targets = ["input"]

  connect() {
    console.log("Fill blanks controller connected")
  }

  checkAnswers(event) {
    if (event) {
      event.preventDefault()
    }

    let allCorrect = true
    let correctCount = 0
    let incorrectCount = 0
    let emptyCount = 0

    this.inputTargets.forEach(input => {
      // Use both data-answer and data-correct-answer for compatibility
      const correctAnswer = (input.dataset.answer || input.dataset.correctAnswer || '').trim().toLowerCase()
      const userAnswer = input.value.trim().toLowerCase()

      console.log("Checking input:", userAnswer, "vs", correctAnswer)
      console.log("Classes before:", input.className)

      // Remove previous styling (including all backgrounds and borders)
      input.classList.remove("border-green-500", "border-red-500", "border-yellow-500",
                            "bg-green-50", "bg-red-50", "bg-yellow-50",
                            "bg-green-100", "bg-red-100", "bg-yellow-100",
                            "bg-white", "bg-white/60", "bg-white/80",
                            "text-gray-900", "font-bold",
                            "border-transparent", "border-cyan-400", "text-black")

      console.log("Classes after remove:", input.className)

      if (userAnswer === "") {
        emptyCount++
        allCorrect = false
        input.classList.add("border-yellow-500", "border-2", "bg-yellow-100", "text-gray-900")
      } else if (userAnswer === correctAnswer) {
        correctCount++
        input.classList.add("border-green-500", "border-2", "bg-green-100", "text-gray-900")
      } else {
        incorrectCount++
        allCorrect = false
        input.classList.add("border-red-500", "border-2", "bg-red-100", "text-gray-900")

        // Shake animation
        input.classList.add("animate-shake")
        setTimeout(() => input.classList.remove("animate-shake"), 500)
      }

      console.log("Classes after add:", input.className)
    })

    this.showFeedback(allCorrect, correctCount, incorrectCount, emptyCount)

    return { allCorrect, correctCount, incorrectCount, emptyCount, total: this.inputTargets.length }
  }

  showFeedback(allCorrect, correctCount, incorrectCount, emptyCount) {
    const existingFeedback = this.element.querySelector(".fill-blanks-feedback")
    if (existingFeedback) {
      existingFeedback.remove()
    }

    const feedbackDiv = document.createElement("div")
    feedbackDiv.className = "fill-blanks-feedback mt-6 p-6 rounded-lg shadow-lg " +
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

  showSolutions(event) {
    if (event) {
      event.preventDefault()
    }

    this.inputTargets.forEach(input => {
      // Use both data-answer and data-correct-answer for compatibility
      const correctAnswer = (input.dataset.answer || input.dataset.correctAnswer || '').trim()

      // Remove previous styling (including all backgrounds and borders)
      input.classList.remove("border-green-500", "border-red-500", "border-yellow-500",
                            "bg-green-50", "bg-red-50", "bg-yellow-50",
                            "bg-green-100", "bg-red-100", "bg-yellow-100",
                            "bg-white", "bg-white/60", "bg-white/80",
                            "text-gray-900", "font-bold",
                            "border-transparent", "border-cyan-400")

      // Show correct answer
      input.value = correctAnswer

      input.classList.add("border-green-500", "border-2", "bg-green-100", "text-gray-900", "font-bold")

      // Force render for textareas
      if (input.tagName === 'TEXTAREA') {
        input.textContent = correctAnswer
      }
    })

    // Show feedback
    const existingFeedback = this.element.querySelector(".fill-blanks-feedback")
    if (existingFeedback) {
      existingFeedback.remove()
    }

    const feedbackDiv = document.createElement("div")
    feedbackDiv.className = "fill-blanks-feedback mt-6 p-6 rounded-lg shadow-lg bg-blue-100 border-4 border-blue-500"

    const title = document.createElement("h2")
    title.className = "text-2xl font-bold mb-4 text-blue-800"
    title.textContent = "💡 Ecco tutte le soluzioni corrette!"

    feedbackDiv.appendChild(title)
    this.element.appendChild(feedbackDiv)
    feedbackDiv.scrollIntoView({ behavior: "smooth", block: "center" })
  }

  reset() {
    this.inputTargets.forEach(input => {
      input.value = ""
      // Remove all styling
      input.classList.remove("border-green-500", "border-red-500", "border-yellow-500",
                            "bg-green-50", "bg-red-50", "bg-yellow-50",
                            "bg-green-100", "bg-red-100", "bg-yellow-100",
                            "bg-white", "text-gray-900", "font-bold",
                            "border-2", "border-4")

      // Restore original background if it was removed
      const hasBgClass = Array.from(input.classList).some(cls => cls.startsWith('bg-'))
      if (!hasBgClass) {
        // No background class left, restore bg-white/60
        input.classList.add("bg-white/60")
      }
    })

    const feedback = this.element.querySelector(".fill-blanks-feedback")
    if (feedback) feedback.remove()
  }
}
