import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="exercise-checker"
export default class extends Controller {
  static targets = ["buttonContainer"]

  connect() {
    console.log("Exercise checker controller connected")
  }

  checkAnswers(event) {
    event.preventDefault()
    
    // Get all groups
    const groups = document.querySelectorAll("[data-controller=\"exercise-group\"]")
    let allCorrect = true
    let feedback = []

    groups.forEach((group, index) => {
      const options = group.querySelectorAll("[data-exercise-group-target=\"option\"]")
      let groupCorrect = true
      let hasSelection = false

      options.forEach(option => {
        const isCorrect = option.dataset.correct === "true"
        const checkbox = option.querySelector("[data-exercise-group-target=\"checkbox\"]")

        // Check if selected by looking for checkmark or bg-orange-100 class
        const checkmark = option.querySelector("[data-exercise-group-target=\"checkmark\"]")
        const isChecked = checkmark
          ? !checkmark.classList.contains("hidden")
          : (checkbox && checkbox.classList.contains("bg-orange-100"))
        const word = option.dataset.word

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
            hint.className = "correct-hint text-sm text-yellow-700 ml-2"
            hint.textContent = "(Risposta corretta)"
            option.querySelector("div").appendChild(hint)
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
    // Remove all highlights and feedback
    const options = document.querySelectorAll("[data-exercise-group-target=\"option\"]")
    options.forEach(option => {
      option.classList.remove("bg-red-100", "bg-green-100", "bg-yellow-100", 
                              "border-2", "border-red-500", "border-green-500", 
                              "border-yellow-500", "rounded-lg")
      const hint = option.querySelector(".correct-hint")
      if (hint) hint.remove()
    })

    const feedback = document.querySelector(".exercise-feedback")
    if (feedback) feedback.remove()
  }
}
