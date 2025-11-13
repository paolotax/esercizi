import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="equivalent-fractions"
export default class extends Controller {
  static targets = ["fractionGroup", "input"]

  connect() {
    console.log("Equivalent fractions controller connected")
  }

  checkAnswers(event) {
    event.preventDefault()

    let totalGroups = 0
    let correctGroups = 0
    let incorrectGroups = 0
    let emptyGroups = 0

    this.fractionGroupTargets.forEach(group => {
      totalGroups++

      const origNum = parseInt(group.dataset.originalNum)
      const origDen = parseInt(group.dataset.originalDen)

      // Get all 4 inputs in this group
      const inputs = group.querySelectorAll('[data-equivalent-fractions-target="input"]')
      const num1Input = inputs[0]
      const den1Input = inputs[1]
      const num2Input = inputs[2]
      const den2Input = inputs[3]

      // Get values
      const num1 = num1Input.value.trim()
      const den1 = den1Input.value.trim()
      const num2 = num2Input.value.trim()
      const den2 = den2Input.value.trim()

      // Remove previous styling
      inputs.forEach(input => {
        input.classList.remove("border-green-500", "border-red-500", "border-yellow-500",
                              "bg-green-50", "bg-red-50", "bg-yellow-50")
      })

      // Check if all fields are filled
      if (!num1 || !den1 || !num2 || !den2) {
        emptyGroups++
        inputs.forEach(input => {
          if (!input.value.trim()) {
            input.classList.add("border-yellow-500", "bg-yellow-50")
          }
        })
        return
      }

      // Parse numbers
      const n1 = parseInt(num1)
      const d1 = parseInt(den1)
      const n2 = parseInt(num2)
      const d2 = parseInt(den2)

      // Validate inputs
      let isValid = true
      let errors = []

      // Check if numbers are valid
      if (isNaN(n1) || isNaN(d1) || isNaN(n2) || isNaN(d2)) {
        isValid = false
        errors.push("Inserisci solo numeri")
      }

      // Check denominators are not zero
      if (d1 === 0 || d2 === 0) {
        isValid = false
        errors.push("Il denominatore non può essere zero")
      }

      // Check limits (max 100)
      if (n1 > 100 || d1 > 100 || n2 > 100 || d2 > 100) {
        isValid = false
        errors.push("Usa numeri ≤ 100")
      }

      // Check if fractions are equivalent to original
      const isFraction1Equivalent = (n1 * origDen) === (d1 * origNum)
      const isFraction2Equivalent = (n2 * origDen) === (d2 * origNum)

      // Check if the two fractions are different
      const areDifferent = (n1 !== n2) || (d1 !== d2)

      if (!isValid) {
        incorrectGroups++
        inputs.forEach(input => {
          input.classList.add("border-red-500", "bg-red-50")
          input.classList.add("animate-shake")
          setTimeout(() => input.classList.remove("animate-shake"), 500)
        })
      } else if (isFraction1Equivalent && isFraction2Equivalent && areDifferent) {
        correctGroups++
        inputs.forEach(input => {
          input.classList.add("border-green-500", "bg-green-50")
        })
      } else {
        incorrectGroups++

        // Mark specific inputs as incorrect
        if (!isFraction1Equivalent) {
          num1Input.classList.add("border-red-500", "bg-red-50")
          den1Input.classList.add("border-red-500", "bg-red-50")
        } else {
          num1Input.classList.add("border-green-500", "bg-green-50")
          den1Input.classList.add("border-green-500", "bg-green-50")
        }

        if (!isFraction2Equivalent) {
          num2Input.classList.add("border-red-500", "bg-red-50")
          den2Input.classList.add("border-red-500", "bg-red-50")
        } else {
          num2Input.classList.add("border-green-500", "bg-green-50")
          den2Input.classList.add("border-green-500", "bg-green-50")
        }

        if (!areDifferent) {
          // Mark both as incorrect if they're the same
          inputs.forEach(input => {
            input.classList.remove("border-green-500", "bg-green-50")
            input.classList.add("border-red-500", "bg-red-50")
          })
        }

        // Shake animation
        inputs.forEach(input => {
          if (input.classList.contains("border-red-500")) {
            input.classList.add("animate-shake")
            setTimeout(() => input.classList.remove("animate-shake"), 500)
          }
        })
      }
    })

    this.showFeedback(correctGroups, incorrectGroups, emptyGroups, totalGroups)
  }

  showSolutions(event) {
    event.preventDefault()

    this.fractionGroupTargets.forEach(group => {
      const origNum = parseInt(group.dataset.originalNum)
      const origDen = parseInt(group.dataset.originalDen)

      // Get all 4 inputs in this group
      const inputs = group.querySelectorAll('[data-equivalent-fractions-target="input"]')
      const num1Input = inputs[0]
      const den1Input = inputs[1]
      const num2Input = inputs[2]
      const den2Input = inputs[3]

      // Remove previous styling
      inputs.forEach(input => {
        input.classList.remove("border-green-500", "border-red-500", "border-yellow-500",
                              "bg-green-50", "bg-red-50", "bg-yellow-50")
        input.classList.add("border-green-500", "bg-green-50")
      })

      // Set solutions: ×2 and ×3
      num1Input.value = origNum * 2
      den1Input.value = origDen * 2
      num2Input.value = origNum * 3
      den2Input.value = origDen * 3
    })

    // Show feedback
    const existingFeedback = this.element.querySelector(".equivalent-fractions-feedback")
    if (existingFeedback) {
      existingFeedback.remove()
    }

    const feedbackDiv = document.createElement("div")
    feedbackDiv.className = "equivalent-fractions-feedback mt-6 p-6 rounded-lg shadow-lg bg-blue-100 border-4 border-blue-500"

    const title = document.createElement("h2")
    title.className = "text-2xl font-bold mb-4 text-blue-800"
    title.textContent = "💡 Ecco alcuni esempi di frazioni equivalenti!"

    const description = document.createElement("p")
    description.className = "text-lg text-blue-700"
    description.textContent = "Ho moltiplicato numeratore e denominatore per 2 e per 3, ma esistono infinite altre frazioni equivalenti!"

    feedbackDiv.appendChild(title)
    feedbackDiv.appendChild(description)
    this.element.appendChild(feedbackDiv)
    feedbackDiv.scrollIntoView({ behavior: "smooth", block: "center" })
  }

  showFeedback(correctGroups, incorrectGroups, emptyGroups, totalGroups) {
    const existingFeedback = this.element.querySelector(".equivalent-fractions-feedback")
    if (existingFeedback) {
      existingFeedback.remove()
    }

    const allCorrect = correctGroups === totalGroups

    const feedbackDiv = document.createElement("div")
    feedbackDiv.className = "equivalent-fractions-feedback mt-6 p-6 rounded-lg shadow-lg " +
                            (allCorrect ? "bg-green-100 border-4 border-green-500" : "bg-orange-100 border-4 border-orange-500")

    const title = document.createElement("h2")
    title.className = "text-2xl font-bold mb-4 " + (allCorrect ? "text-green-800" : "text-orange-800")
    title.textContent = allCorrect ? "🎉 Eccellente! Tutte le frazioni sono corrette!" : "📝 Controlla le frazioni evidenziate"

    const stats = document.createElement("div")
    stats.className = "text-lg space-y-2"
    stats.innerHTML = `
      ${correctGroups > 0 ? `<p class="text-green-700">✅ Corrette: ${correctGroups}/${totalGroups}</p>` : ''}
      ${incorrectGroups > 0 ? `<p class="text-red-700">❌ Errate: ${incorrectGroups}/${totalGroups}</p>` : ''}
      ${emptyGroups > 0 ? `<p class="text-yellow-700">⚠️ Da completare: ${emptyGroups}/${totalGroups}</p>` : ''}
    `

    feedbackDiv.appendChild(title)
    feedbackDiv.appendChild(stats)

    if (!allCorrect) {
      const hint = document.createElement("p")
      hint.className = "mt-4 text-base text-gray-700"
      hint.innerHTML = "💡 <strong>Ricorda:</strong> per ottenere frazioni equivalenti, moltiplica (o dividi) numeratore e denominatore per lo stesso numero. Le due frazioni devono essere diverse tra loro!"
      feedbackDiv.appendChild(hint)

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

    const feedback = this.element.querySelector(".equivalent-fractions-feedback")
    if (feedback) feedback.remove()
  }
}
