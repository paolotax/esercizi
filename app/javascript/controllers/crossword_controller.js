import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="crossword"
export default class extends Controller {
  connect() {
    console.log("Crossword controller connected")

    // Add event listeners to auto-advance to next input
    this.element.querySelectorAll('input[type="text"]').forEach((input, index, inputs) => {
      input.addEventListener('input', (e) => {
        if (e.target.value.length === 1 && index < inputs.length - 1) {
          // Find next input that is not readonly
          let nextIndex = index + 1
          while (nextIndex < inputs.length && inputs[nextIndex].readOnly) {
            nextIndex++
          }
          if (nextIndex < inputs.length) {
            inputs[nextIndex].focus()
          }
        }
      })

      input.addEventListener('keydown', (e) => {
        if (e.key === 'Backspace' && e.target.value === '' && index > 0) {
          // Find previous input that is not readonly
          let prevIndex = index - 1
          while (prevIndex >= 0 && inputs[prevIndex].readOnly) {
            prevIndex--
          }
          if (prevIndex >= 0) {
            e.preventDefault()
            inputs[prevIndex].focus()
          }
        }
      })
    })
  }

  checkAnswers(event) {
    event.preventDefault()

    const inputs = this.element.querySelectorAll('input[type="text"]')
    let allCorrect = true
    let correctCount = 0
    let incorrectCount = 0
    let emptyCount = 0

    inputs.forEach(input => {
      const correctAnswer = input.dataset.correctAnswer.trim().toUpperCase()
      const userAnswer = input.value.trim().toUpperCase()

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
    const existingFeedback = this.element.querySelector(".crossword-feedback")
    if (existingFeedback) {
      existingFeedback.remove()
    }

    const feedbackDiv = document.createElement("div")
    feedbackDiv.className = "crossword-feedback mt-6 p-6 rounded-lg shadow-lg " +
                            (allCorrect ? "bg-green-100 border-4 border-green-500" : "bg-orange-100 border-4 border-orange-500")

    const title = document.createElement("h2")
    title.className = "text-2xl font-bold mb-4 " + (allCorrect ? "text-green-800" : "text-orange-800")
    title.textContent = allCorrect ? "🎉 Cruciverba completato!" : "📝 Controlla le lettere evidenziate"

    const stats = document.createElement("div")
    stats.className = "text-lg space-y-2"
    stats.innerHTML = `
      ${correctCount > 0 ? `<p class="text-green-700">✅ Lettere corrette: ${correctCount}</p>` : ''}
      ${incorrectCount > 0 ? `<p class="text-red-700">❌ Lettere errate: ${incorrectCount}</p>` : ''}
      ${emptyCount > 0 ? `<p class="text-yellow-700">⚠️ Lettere mancanti: ${emptyCount}</p>` : ''}
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
    const inputs = this.element.querySelectorAll('input[type="text"]')
    inputs.forEach(input => {
      input.value = ""
      input.classList.remove("border-green-500", "border-red-500", "border-yellow-500",
                            "bg-green-50", "bg-red-50", "bg-yellow-50")
    })

    const feedback = this.element.querySelector(".crossword-feedback")
    if (feedback) feedback.remove()
  }
}
