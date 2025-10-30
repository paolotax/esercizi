import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="exercise-checker"
export default class extends Controller {
  static targets = ["buttonContainer"]

  connect() {
    console.log("Exercise checker controller connected")
  }

  checkAnswers(event) {
    event.preventDefault()

    // Get all groups (both exercise-group and card-selector) within this controller's element
    const exerciseGroups = this.element.querySelectorAll("[data-controller=\"exercise-group\"]")
    const cardGroups = this.element.querySelectorAll("[data-controller=\"card-selector\"]")
    const allGroups = [...exerciseGroups, ...cardGroups]

    // Get flower matcher controller if present
    const flowerMatcher = this.element.querySelector("[data-controller=\"flower-matcher\"]")

    // Get all input fields with correct answers within this controller's element
    const inputFields = this.element.querySelectorAll("input[data-correct-answer]")

    let allCorrect = true
    let feedback = []

    // Check flower matching exercise first
    if (flowerMatcher) {
      const flowerController = this.application.getControllerForElementAndIdentifier(flowerMatcher, "flower-matcher")
      if (flowerController) {
        const result = flowerController.checkAnswers()
        if (!result.complete) {
          allCorrect = false
          feedback.push(`Fiori: ${result.message}`)
        } else if (result.allCorrect) {
          feedback.push(`Fiori: ✅ Tutti corretti! (${result.correct}/${result.total})`)
        } else {
          allCorrect = false
          feedback.push(`Fiori: ⚠️ ${result.message}`)
        }
      }
    }

    // Check input fields first
    if (inputFields.length > 0) {
      let inputsCorrect = 0
      let inputsIncorrect = 0
      let inputsEmpty = 0

      inputFields.forEach(input => {
        const correctAnswer = input.dataset.correctAnswer.trim().replace(/\s+/g, '')
        const userAnswer = input.value.trim().replace(/\s+/g, '')

        // Remove all previous styling
        input.classList.remove("border-yellow-500", "border-green-500", "border-red-500",
                               "border-gray-300", "border-2", "border-4",
                               "bg-yellow-50", "bg-green-50", "bg-red-50")

        if (userAnswer === "") {
          inputsEmpty++
          input.classList.add("border-yellow-500", "border-4", "bg-yellow-50")
        } else if (userAnswer === correctAnswer) {
          inputsCorrect++
          input.classList.add("border-green-500", "border-4", "bg-green-50")
        } else {
          inputsIncorrect++
          allCorrect = false
          input.classList.add("border-red-500", "border-4", "bg-red-50")

          // Show shake animation
          input.classList.add("animate-shake")
          setTimeout(() => {
            input.classList.remove("animate-shake")
          }, 500)
        }
      })

      if (inputsEmpty > 0) {
        allCorrect = false
        feedback.push(`Campi da completare: ${inputsEmpty} ⚠️`)
      }
      if (inputsCorrect > 0) {
        feedback.push(`Campi corretti: ${inputsCorrect} ✅`)
      }
      if (inputsIncorrect > 0) {
        feedback.push(`Campi errati: ${inputsIncorrect} ❌`)
      }
    }

    allGroups.forEach((group, index) => {
      // Determine if this is a card-selector group
      const isCardGroup = group.hasAttribute("data-controller") &&
                          group.getAttribute("data-controller").includes("card-selector")

      // Get options based on group type
      let options
      if (isCardGroup) {
        options = group.querySelectorAll("[data-card-selector-target=\"card\"]")
      } else {
        options = group.querySelectorAll("[data-exercise-group-target=\"option\"]")
      }

      let groupCorrect = true
      let hasSelection = false

      options.forEach(option => {
        const isCorrect = option.dataset.correct === "true"
        const word = option.dataset.word
        let isChecked = false

        // Determine if checked based on group type
        if (isCardGroup) {
          // For card-selector: check if has bg-orange-100 class
          isChecked = option.classList.contains("bg-orange-100")
        } else {
          // For exercise-group: check for checkmark
          const checkmark = option.querySelector("[data-exercise-group-target=\"checkmark\"]")
          if (checkmark) {
            isChecked = !checkmark.classList.contains("hidden")
          }
        }

        if (isChecked) {
          hasSelection = true
          if (!isCorrect) {
            groupCorrect = false
            // Highlight incorrect answer
            option.classList.add("bg-red-100", "border-2", "border-red-500", "rounded-lg")
            
            // Show shake animation
            option.classList.add("animate-shake")
            setTimeout(() => {
              option.classList.remove("animate-shake")
            }, 500)
          } else {
            // Highlight correct answer
            option.classList.add("bg-green-100", "border-2", "border-green-500", "rounded-lg")
          }
        } else if (isCorrect) {
          // Show the correct answer if not selected
          groupCorrect = false
          option.classList.add("bg-yellow-100", "border-2", "border-yellow-500", "rounded-lg")
          const correctHint = option.querySelector(".correct-hint")
          if (!correctHint) {
            const hint = document.createElement("span")
            hint.className = "correct-hint text-sm text-yellow-700 ml-2 block mt-1"
            hint.textContent = "(Risposta corretta)"
            // Try to find a container element (div or span), otherwise append to option
            const container = option.querySelector("div") || option.querySelector("span") || option
            if (container === option) {
              option.appendChild(hint)
            } else {
              container.parentElement.appendChild(hint)
            }
          }
        }
      })

      if (!hasSelection) {
        groupCorrect = false
        feedback.push(`Gruppo ${index + 1}: Seleziona una risposta!`)
      } else if (groupCorrect) {
        feedback.push(`Gruppo ${index + 1}: ✅ Corretto!`)
      } else {
        feedback.push(`Gruppo ${index + 1}: ❌ Riprova!`)
      }

      allCorrect = allCorrect && groupCorrect && hasSelection
    })

    // Show feedback
    this.showFeedback(feedback, allCorrect)
  }

  showFeedback(messages, allCorrect) {
    // Remove existing feedback if any
    const existingFeedback = document.querySelector(".exercise-feedback")
    if (existingFeedback) {
      existingFeedback.remove()
    }

    const feedbackDiv = document.createElement("div")
    feedbackDiv.className = "exercise-feedback mt-6 p-6 rounded-lg shadow-lg " + 
                            (allCorrect ? "bg-green-100 border-4 border-green-500" : "bg-orange-100 border-4 border-orange-500")
    
    const title = document.createElement("h2")
    title.className = "text-2xl font-bold mb-4 " + (allCorrect ? "text-green-800" : "text-orange-800")
    title.textContent = allCorrect ? "🎉 Eccellente! Tutte le risposte sono corrette!" : "📝 Controlla le risposte evidenziate"
    
    const messageList = document.createElement("ul")
    messageList.className = "space-y-2"
    
    messages.forEach(msg => {
      const li = document.createElement("li")
      li.className = "text-lg " + (allCorrect ? "text-green-700" : "text-orange-700")
      li.textContent = msg
      messageList.appendChild(li)
    })

    feedbackDiv.appendChild(title)
    feedbackDiv.appendChild(messageList)

    // Add retry button if not all correct
    if (!allCorrect) {
      const retryButton = document.createElement("button")
      retryButton.className = "mt-4 bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-6 rounded-full transition"
      retryButton.textContent = "🔄 Riprova"
      retryButton.onclick = () => this.resetExercise()
      feedbackDiv.appendChild(retryButton)
    }

    // Insert feedback before the check button
    this.buttonContainerTarget.insertBefore(feedbackDiv, this.buttonContainerTarget.firstChild)

    // Scroll to feedback
    feedbackDiv.scrollIntoView({ behavior: "smooth", block: "center" })
  }

  resetExercise() {
    // Remove all highlights and feedback from options
    const options = this.element.querySelectorAll("[data-exercise-group-target=\"option\"]")
    options.forEach(option => {
      option.classList.remove("bg-red-100", "bg-green-100", "bg-yellow-100",
                              "border-2", "border-red-500", "border-green-500",
                              "border-yellow-500", "rounded-lg")
      const hint = option.querySelector(".correct-hint")
      if (hint) hint.remove()
    })

    // Remove highlights from card-selector options
    const cards = this.element.querySelectorAll("[data-card-selector-target=\"card\"]")
    cards.forEach(card => {
      card.classList.remove("bg-red-100", "bg-green-100", "bg-yellow-100",
                            "border-2", "border-red-500", "border-green-500",
                            "border-yellow-500")
    })

    // Remove highlights from input fields and restore original styling
    const inputFields = this.element.querySelectorAll("input[data-correct-answer]")
    inputFields.forEach(input => {
      input.classList.remove("border-yellow-500", "border-green-500", "border-red-500",
                             "border-4", "bg-yellow-50", "bg-green-50", "bg-red-50")
      input.classList.add("border-gray-300", "border-2")
    })

    const feedback = this.element.querySelector(".exercise-feedback")
    if (feedback) feedback.remove()
  }
}
