import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="exercise-checker"
export default class extends Controller {
  static targets = ["buttonContainer"]

  connect() {
    console.log("Exercise checker controller connected")
  }

  selectAnswer(event) {
    const clickedButton = event.currentTarget
    const question = clickedButton.dataset.question

    // Find all buttons in the same question group
    const allButtons = this.element.querySelectorAll(`button[data-question="${question}"]`)

    // Deselect all buttons in this group
    allButtons.forEach(button => {
      button.classList.remove('bg-blue-500', 'border-blue-500', 'text-white')
      button.classList.add('bg-transparent', 'border-gray-300')
    })

    // Select the clicked button
    clickedButton.classList.remove('bg-transparent', 'border-gray-300')
    clickedButton.classList.add('bg-blue-500', 'border-blue-500', 'text-white')
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

    // Check checkboxes (for exercises like "cerchia i numeri decimali")
    const checkboxes = this.element.querySelectorAll('input[type="checkbox"][data-correct-answer]')
    if (checkboxes.length > 0) {
      let checkboxCorrect = 0
      let checkboxIncorrect = 0

      checkboxes.forEach(checkbox => {
        const shouldBeChecked = checkbox.dataset.correctAnswer === "true"
        const isChecked = checkbox.checked
        const label = checkbox.closest('label')

        // Remove previous styling
        if (label) {
          const span = label.querySelector('span')
          if (span) {
            span.classList.remove("border-red-500", "border-green-500", "border-yellow-500",
                                  "bg-red-100", "bg-green-100", "bg-yellow-50")
          }
        }

        // Check correctness
        if ((shouldBeChecked && isChecked) || (!shouldBeChecked && !isChecked)) {
          // Correct
          checkboxCorrect++
          if (isChecked && label) {
            const span = label.querySelector('span')
            if (span) {
              span.classList.add("border-green-500", "bg-green-100")
            }
          }
        } else {
          // Incorrect
          checkboxIncorrect++
          allCorrect = false
          if (label) {
            const span = label.querySelector('span')
            if (span) {
              if (isChecked) {
                // Checked but shouldn't be
                span.classList.add("border-red-500", "bg-red-100")
                span.classList.add("animate-shake")
                setTimeout(() => span.classList.remove("animate-shake"), 500)
              } else if (shouldBeChecked) {
                // Should be checked but isn't
                span.classList.add("border-yellow-500", "bg-yellow-50")
              }
            }
          }
        }
      })

      if (checkboxCorrect > 0) {
        feedback.push(`Selezioni corrette: ${checkboxCorrect} ✅`)
      }
      if (checkboxIncorrect > 0) {
        feedback.push(`Selezioni errate: ${checkboxIncorrect} ❌`)
      }
    }

    // Check radio buttons and button-style answers
    const radioButtons = this.element.querySelectorAll('input[type="radio"][data-correct-answer]')
    const buttonAnswers = this.element.querySelectorAll('button[data-question][data-correct-answer]')

    if (radioButtons.length > 0 || buttonAnswers.length > 0) {
      let answerGroups = new Map()

      // Process radio buttons
      radioButtons.forEach(radio => {
        const groupName = radio.name
        if (!answerGroups.has(groupName)) {
          answerGroups.set(groupName, { type: 'radio', items: [] })
        }
        answerGroups.get(groupName).items.push(radio)
      })

      // Process button answers
      buttonAnswers.forEach(button => {
        const groupName = button.dataset.question
        if (!answerGroups.has(groupName)) {
          answerGroups.set(groupName, { type: 'button', items: [] })
        }
        answerGroups.get(groupName).items.push(button)
      })

      let radioCorrect = 0
      let radioIncorrect = 0
      let radioEmpty = 0

      answerGroups.forEach((group, groupName) => {
        let selectedItem = null

        // Find the selected item based on type
        if (group.type === 'radio') {
          selectedItem = group.items.find(r => r.checked)
        } else if (group.type === 'button') {
          selectedItem = group.items.find(b => b.classList.contains('bg-blue-500'))
        }

        // Remove all previous styling
        group.items.forEach(item => {
          if (group.type === 'radio') {
            const label = item.closest('label')
            if (label) {
              label.classList.remove("bg-yellow-50", "bg-green-50", "bg-red-50",
                                   "border-2", "border-yellow-500", "border-green-500", "border-red-500",
                                   "rounded-lg", "px-2", "py-1")
            }
          } else if (group.type === 'button') {
            item.classList.remove("bg-yellow-50", "bg-green-50", "bg-red-50",
                                 "border-yellow-500", "border-green-500", "border-red-500",
                                 "bg-blue-500", "border-blue-500", "text-white")
          }
        })

        if (!selectedItem) {
          // No selection made
          radioEmpty++
          allCorrect = false
          group.items.forEach(item => {
            if (group.type === 'radio') {
              const label = item.closest('label')
              if (label) {
                label.classList.add("bg-yellow-50", "border-2", "border-yellow-500", "rounded-lg", "px-2", "py-1")
              }
            } else if (group.type === 'button') {
              item.classList.add("bg-yellow-50", "border-yellow-500")
            }
          })
        } else {
          const isCorrect = selectedItem.dataset.correctAnswer === "true"

          if (isCorrect) {
            radioCorrect++
            if (group.type === 'radio') {
              const label = selectedItem.closest('label')
              if (label) {
                label.classList.add("bg-green-50", "border-2", "border-green-500", "rounded-lg", "px-2", "py-1")
              }
            } else if (group.type === 'button') {
              selectedItem.classList.remove('bg-blue-500', 'border-blue-500', 'text-white')
              selectedItem.classList.add("bg-green-50", "border-green-500")
            }
          } else {
            radioIncorrect++
            allCorrect = false

            if (group.type === 'radio') {
              const label = selectedItem.closest('label')
              if (label) {
                label.classList.add("bg-red-50", "border-2", "border-red-500", "rounded-lg", "px-2", "py-1")
                label.classList.add("animate-shake")
                setTimeout(() => label.classList.remove("animate-shake"), 500)
              }
            } else if (group.type === 'button') {
              selectedItem.classList.remove('bg-blue-500', 'border-blue-500', 'text-white')
              selectedItem.classList.add("bg-red-50", "border-red-500")
              selectedItem.classList.add("animate-shake")
              setTimeout(() => selectedItem.classList.remove("animate-shake"), 500)
            }

            // Highlight the correct answer in yellow
            group.items.forEach(item => {
              if (item.dataset.correctAnswer === "true") {
                if (group.type === 'radio') {
                  const correctLabel = item.closest('label')
                  if (correctLabel) {
                    correctLabel.classList.add("bg-yellow-50", "border-2", "border-yellow-500", "rounded-lg", "px-2", "py-1")
                  }
                } else if (group.type === 'button') {
                  item.classList.add("bg-yellow-50", "border-yellow-500")
                }
              }
            })
          }
        }
      })

      if (radioEmpty > 0) {
        feedback.push(`Risposte da selezionare: ${radioEmpty} ⚠️`)
      }
      if (radioCorrect > 0) {
        feedback.push(`Risposte corrette: ${radioCorrect} ✅`)
      }
      if (radioIncorrect > 0) {
        feedback.push(`Risposte errate: ${radioIncorrect} ❌`)
      }
    }

    // Check text input fields
    const textInputFields = this.element.querySelectorAll("input[type='text'][data-correct-answer], textarea[data-correct-answer]")
    if (textInputFields.length > 0) {
      let inputsCorrect = 0
      let inputsIncorrect = 0
      let inputsEmpty = 0

      textInputFields.forEach(input => {
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
            // hint.textContent = "(Risposta corretta)"
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
    this.buttonContainerTarget.insertBefore(feedbackDiv, this.buttonContainerTarget.firstChild)

    // Scroll to feedback
    feedbackDiv.scrollIntoView({ behavior: "smooth", block: "center" })
  }

  showSolutions(event) {
    event.preventDefault()

    // First reset the exercise
    this.resetExercise()

    // Get all groups (both exercise-group and card-selector)
    const exerciseGroups = this.element.querySelectorAll("[data-controller=\"exercise-group\"]")
    const cardGroups = this.element.querySelectorAll("[data-controller=\"card-selector\"]")
    const allGroups = [...exerciseGroups, ...cardGroups]

    // Show correct answers for all groups
    allGroups.forEach(group => {
      const isCardGroup = group.hasAttribute("data-controller") &&
                          group.getAttribute("data-controller").includes("card-selector")

      let options
      if (isCardGroup) {
        options = group.querySelectorAll("[data-card-selector-target=\"card\"]")
      } else {
        options = group.querySelectorAll("[data-exercise-group-target=\"option\"]")
      }

      options.forEach(option => {
        const isCorrect = option.dataset.correct === "true"
        
        if (isCorrect) {
          // Highlight correct answers in green
          option.classList.add("bg-green-100", "border-2", "border-green-500", "rounded-lg")
          
          // For exercise-group, show the checkmark
          if (!isCardGroup) {
            const checkmark = option.querySelector("[data-exercise-group-target=\"checkmark\"]")
            if (checkmark) {
              checkmark.classList.remove("hidden")
            }
          } else {
            // For card-selector, add the selection class
            option.classList.add("bg-orange-100")
          }
        }
      })
    })

    // Show correct answers for checkboxes
    const checkboxes = this.element.querySelectorAll('input[type="checkbox"][data-correct-answer]')
    checkboxes.forEach(checkbox => {
      const shouldBeChecked = checkbox.dataset.correctAnswer === "true"
      const label = checkbox.closest('label')

      if (shouldBeChecked) {
        checkbox.checked = true
        if (label) {
          const span = label.querySelector('span')
          if (span) {
            span.classList.add("border-green-500", "bg-green-100")
          }
        }
      } else {
        checkbox.checked = false
      }
    })

    // Show correct answers for radio buttons and button-style answers
    const radioButtons = this.element.querySelectorAll('input[type="radio"][data-correct-answer]')
    const buttonAnswers = this.element.querySelectorAll('button[data-question][data-correct-answer]')

    if (radioButtons.length > 0) {
      const radioGroups = new Map()
      radioButtons.forEach(radio => {
        const groupName = radio.name
        if (!radioGroups.has(groupName)) {
          radioGroups.set(groupName, [])
        }
        radioGroups.get(groupName).push(radio)
      })

      radioGroups.forEach((radios) => {
        radios.forEach(radio => {
          const isCorrect = radio.dataset.correctAnswer === "true"
          const label = radio.closest('label')

          if (isCorrect) {
            radio.checked = true
            if (label) {
              label.classList.add("bg-green-50", "border-2", "border-green-500", "rounded-lg", "px-2", "py-1")
            }
          }
        })
      })
    }

    if (buttonAnswers.length > 0) {
      const buttonGroups = new Map()
      buttonAnswers.forEach(button => {
        const groupName = button.dataset.question
        if (!buttonGroups.has(groupName)) {
          buttonGroups.set(groupName, [])
        }
        buttonGroups.get(groupName).push(button)
      })

      buttonGroups.forEach((buttons) => {
        buttons.forEach(button => {
          const isCorrect = button.dataset.correctAnswer === "true"

          if (isCorrect) {
            button.classList.remove('bg-transparent', 'border-gray-300', 'bg-blue-500', 'border-blue-500', 'text-white')
            button.classList.add("bg-green-50", "border-green-500")
          }
        })
      })
    }

    // Fill in correct answers for text input fields
    const textInputFields = this.element.querySelectorAll("input[type='text'][data-correct-answer], textarea[data-correct-answer]")
    textInputFields.forEach(input => {
      const correctAnswer = input.dataset.correctAnswer.trim()
      input.value = correctAnswer
      input.classList.add("border-green-500", "border-4", "bg-green-50")
    })

    // Show flower matcher solutions if present
    const flowerMatcher = this.element.querySelector("[data-controller=\"flower-matcher\"]")
    if (flowerMatcher) {
      const flowerController = this.application.getControllerForElementAndIdentifier(flowerMatcher, "flower-matcher")
      if (flowerController && flowerController.showSolutions) {
        flowerController.showSolutions()
      }
    }

    // Show feedback message
    this.showSolutionFeedback()
  }

  showSolutionFeedback() {
    // Remove existing feedback if any
    const existingFeedback = document.querySelector(".exercise-feedback")
    if (existingFeedback) {
      existingFeedback.remove()
    }

    const feedbackDiv = document.createElement("div")
    feedbackDiv.className = "exercise-feedback my-6 p-6 rounded-lg shadow-lg bg-blue-100 border-4 border-blue-500"
    
    const title = document.createElement("h2")
    title.className = "text-2xl font-bold mb-4 text-blue-800"
    title.textContent = "💡 Soluzioni mostrate!"
    
    const message = document.createElement("p")
    message.className = "text-lg text-blue-700"
    message.textContent = "Tutte le risposte corrette sono evidenziate in verde."
    
    feedbackDiv.appendChild(title)
    feedbackDiv.appendChild(message)

    // Insert feedback before the buttons
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
      
      // Hide checkmarks
      const checkmark = option.querySelector("[data-exercise-group-target=\"checkmark\"]")
      if (checkmark) {
        checkmark.classList.add("hidden")
      }
    })

    // Remove highlights from card-selector options
    const cards = this.element.querySelectorAll("[data-card-selector-target=\"card\"]")
    cards.forEach(card => {
      card.classList.remove("bg-red-100", "bg-green-100", "bg-yellow-100",
                            "border-2", "border-red-500", "border-green-500",
                            "border-yellow-500", "bg-orange-100")
    })

    // Remove highlights from checkboxes and uncheck them
    const checkboxes = this.element.querySelectorAll('input[type="checkbox"][data-correct-answer]')
    checkboxes.forEach(checkbox => {
      checkbox.checked = false
      const label = checkbox.closest('label')
      if (label) {
        const span = label.querySelector('span')
        if (span) {
          span.classList.remove("border-red-500", "border-green-500", "border-yellow-500",
                                "bg-red-100", "bg-green-100", "bg-yellow-50")
        }
      }
    })

    // Remove highlights from radio buttons and uncheck them
    const radioButtons = this.element.querySelectorAll('input[type="radio"][data-correct-answer]')
    radioButtons.forEach(radio => {
      radio.checked = false
      const label = radio.closest('label')
      if (label) {
        label.classList.remove("bg-yellow-50", "bg-green-50", "bg-red-50",
                              "border-2", "border-yellow-500", "border-green-500", "border-red-500",
                              "rounded-lg", "px-2", "py-1")
      }
    })

    // Remove highlights from button-style answers
    const buttonAnswers = this.element.querySelectorAll('button[data-question][data-correct-answer]')
    buttonAnswers.forEach(button => {
      button.classList.remove("bg-blue-500", "bg-yellow-50", "bg-green-50", "bg-red-50",
                             "border-blue-500", "border-yellow-500", "border-green-500", "border-red-500", "text-white")
      button.classList.add("bg-transparent", "border-gray-300")
    })

    // Remove highlights from text input fields and restore original styling
    const textInputFields = this.element.querySelectorAll("input[type='text'][data-correct-answer], textarea[data-correct-answer]")
    textInputFields.forEach(input => {
      input.classList.remove("border-yellow-500", "border-green-500", "border-red-500",
                             "border-4", "bg-yellow-50", "bg-green-50", "bg-red-50",
                             "border-gray-300", "border-gray-500", "border-2")
      input.value = ""
    })

    const feedback = this.element.querySelector(".exercise-feedback")
    if (feedback) feedback.remove()
  }
}
