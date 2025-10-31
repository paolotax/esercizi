import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="fill-blanks"
export default class extends Controller {
  static targets = ["input"]

  connect() {
    console.log("Fill blanks controller connected")
  }

  checkAnswers(event) {
    event.preventDefault()

    let allCorrect = true
    let correctCount = 0
    let incorrectCount = 0
    let emptyCount = 0

    this.inputTargets.forEach(input => {
      const correctAnswer = input.dataset.answer.trim().toLowerCase()
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

  reset() {
    this.inputTargets.forEach(input => {
      input.value = ""
      input.classList.remove("border-green-500", "border-red-500", "border-yellow-500",
                            "bg-green-50", "bg-red-50", "bg-yellow-50")
    })

    const feedback = this.element.querySelector(".fill-blanks-feedback")
    if (feedback) feedback.remove()
  }
}
