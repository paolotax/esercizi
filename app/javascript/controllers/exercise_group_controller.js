import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="exercise-group"
export default class extends Controller {
  static targets = ["option", "checkbox", "checkmark"]

  connect() {
    console.log("Exercise group controller connected")
  }

  toggleCheck(event) {
    const option = event.currentTarget
    const checkbox = option.querySelector("[data-exercise-group-target=\"checkbox\"]")
    const checkmark = option.querySelector("[data-exercise-group-target=\"checkmark\"]")
    const isCorrect = option.dataset.correct === "true"

    console.log("toggleCheck called", {
      checkbox: checkbox,
      checkmark: checkmark,
      text: checkbox ? checkbox.textContent.trim() : 'no checkbox'
    })

    // Get all options in this group to deselect others (single selection behavior)
    const group = option.closest("[data-controller=\"exercise-group\"]")
    const allOptions = group.querySelectorAll("[data-exercise-group-target=\"option\"]")

    // Check if this option is already selected
    const isCurrentlySelected = checkmark ?
      !checkmark.classList.contains("hidden") :
      checkbox.classList.contains("bg-orange-300") ||
      checkbox.classList.contains("bg-pink-300") ||
      checkbox.classList.contains("bg-sky-300") ||
      checkbox.classList.contains("bg-purple-300") ||
      checkbox.classList.contains("bg-green-300") ||
      checkbox.classList.contains("bg-blue-300")

    // Deselect all options in this group first
    allOptions.forEach(opt => {
      const cb = opt.querySelector("[data-exercise-group-target=\"checkbox\"]")
      const cm = opt.querySelector("[data-exercise-group-target=\"checkmark\"]")
      if (cm) cm.classList.add("hidden")
      cb.classList.remove("bg-gray-100", "bg-orange-300", "bg-pink-300", "bg-sky-300",
                          "bg-purple-300", "bg-green-300", "bg-green-200", "bg-gray-200", "bg-blue-300")
      cb.classList.add("bg-white") // Reset to white
    })

    // If it wasn't selected, select it now
    if (!isCurrentlySelected) {
      if (checkmark) {
        // For pages with checkmark (pag010, pag010gen, pag043, pag051)
        checkmark.classList.remove("hidden")
        if (isCorrect) {
          checkbox.classList.add("bg-green-200")
        } else {
          checkbox.classList.add("bg-gray-200")
        }
      } else {
        // For pages without checkmark (pag050, pag022, pag167)
        // Color based on the letter or text content
        const text = checkbox.textContent.trim()

        // Map for single vowels (pag050)
        const vowelColorMap = {
          'A': 'bg-orange-300',
          'E': 'bg-pink-300',
          'I': 'bg-sky-300',
          'O': 'bg-purple-300',
          'U': 'bg-green-300'
        }

        // Map for text content (pag167)
        const textColorMap = {
          'SCIA': 'bg-orange-300',
          'SCIO': 'bg-purple-300',
          'SCIU': 'bg-green-300',
          'SCE': 'bg-pink-300',
          'SCI': 'bg-sky-300'
        }

        // Determine color: check vowels first, then text, then default to blue
        let bgColor = vowelColorMap[text] || textColorMap[text] || 'bg-blue-300'

        console.log("Adding color", {
          text: text,
          bgColor: bgColor,
          checkbox: checkbox
        })

        checkbox.classList.remove("bg-white") // Remove white background
        checkbox.classList.add(bgColor)
      }
    }
    // If it was already selected, it's now deselected (from the forEach loop above)
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
        const checkmark = option.querySelector("[data-exercise-group-target=\"checkmark\"]")
        const isChecked = !checkmark.classList.contains("hidden")
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
            hint.className = "correct-hint text-sm text-yellow-700 ml-2 block mt-1"
            // hint.textContent = "(Risposta corretta)"
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
    feedbackDiv.className = "exercise-feedback my-6 p-6 rounded-lg shadow-lg " + 
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
    const checkButton = document.querySelector("button[data-action*=\"checkAnswers\"]")
    checkButton.parentElement.insertBefore(feedbackDiv, checkButton)

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
