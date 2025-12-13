import { Controller } from "@hotwired/stimulus"
import JSConfetti from "js-confetti"

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

    // Get fill-blanks controllers if present
    const fillBlanksControllers = this.element.querySelectorAll("[data-controller*=\"fill-blanks\"]")

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

    // Check fill-blanks exercises
    if (fillBlanksControllers.length > 0) {
      fillBlanksControllers.forEach(fillBlanksElement => {
        const fillBlanksController = this.application.getControllerForElementAndIdentifier(fillBlanksElement, "fill-blanks")
        if (fillBlanksController && fillBlanksController.checkAnswers) {
          const result = fillBlanksController.checkAnswers()
          if (result) {
            if (!result.allCorrect) {
              allCorrect = false
            }
            if (result.correctCount > 0) {
              feedback.push(`Input corretti: ${result.correctCount}/${result.total} ✅`)
            }
            if (result.incorrectCount > 0) {
              feedback.push(`Input errati: ${result.incorrectCount} ❌`)
            }
            if (result.emptyCount > 0) {
              feedback.push(`Input da completare: ${result.emptyCount} ⚠️`)
            }
          }
        }
      })
    }

    // Check sortable exercises
    const sortableControllers = this.element.querySelectorAll("[data-controller*=\"sortable\"]")
    if (sortableControllers.length > 0) {
      sortableControllers.forEach((sortableElement, index) => {
        const sortableController = this.application.getControllerForElementAndIdentifier(sortableElement, "sortable")
        if (sortableController && sortableController.checkAnswers) {
          const result = sortableController.checkAnswers()
          if (!result.allCorrect) {
            allCorrect = false
          }
          if (result.correctCount > 0) {
            feedback.push(`Ordinamento ${index + 1}: ${result.correctCount}/${result.total} corretti ✅`)
          }
          if (result.incorrectCount > 0) {
            feedback.push(`Ordinamento ${index + 1}: ${result.incorrectCount} errati ❌`)
          }
        }
      })
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
                                  "bg-red-100", "bg-green-100", "bg-yellow-50",
                                  "dark:bg-red-900/60", "dark:bg-green-900/60", "dark:bg-yellow-900/50")
          }
        }

        // Check correctness
        if ((shouldBeChecked && isChecked) || (!shouldBeChecked && !isChecked)) {
          // Correct
          checkboxCorrect++
          if (isChecked && label) {
            const span = label.querySelector('span')
            if (span) {
              span.classList.add("border-green-500", "bg-green-100", "dark:bg-green-900/60")
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
                span.classList.add("border-red-500", "bg-red-100", "dark:bg-red-900/60")
                span.classList.add("animate-shake")
                setTimeout(() => span.classList.remove("animate-shake"), 500)
              } else if (shouldBeChecked) {
                // Should be checked but isn't
                span.classList.add("border-yellow-500", "bg-yellow-50", "dark:bg-yellow-900/50")
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
                                   "dark:bg-yellow-900/50", "dark:bg-green-900/50", "dark:bg-red-900/50",
                                   "border-2", "border-yellow-500", "border-green-500", "border-red-500",
                                   "rounded-lg", "px-2", "py-1")
            }
          } else if (group.type === 'button') {
            item.classList.remove("bg-yellow-50", "bg-green-50", "bg-red-50",
                                 "dark:bg-yellow-900/50", "dark:bg-green-900/50", "dark:bg-red-900/50",
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
                label.classList.add("bg-yellow-50", "dark:bg-yellow-900/50", "border-2", "border-yellow-500", "rounded-lg", "px-2", "py-1")
              }
            } else if (group.type === 'button') {
              item.classList.add("bg-yellow-50", "dark:bg-yellow-900/50", "border-yellow-500")
            }
          })
        } else {
          const isCorrect = selectedItem.dataset.correctAnswer === "true"

          if (isCorrect) {
            radioCorrect++
            if (group.type === 'radio') {
              const label = selectedItem.closest('label')
              if (label) {
                label.classList.add("bg-green-50", "dark:bg-green-900/50", "border-2", "border-green-500", "rounded-lg", "px-2", "py-1")
              }
            } else if (group.type === 'button') {
              selectedItem.classList.remove('bg-blue-500', 'border-blue-500', 'text-white')
              selectedItem.classList.add("bg-green-50", "dark:bg-green-900/50", "border-green-500")
            }
          } else {
            radioIncorrect++
            allCorrect = false

            if (group.type === 'radio') {
              const label = selectedItem.closest('label')
              if (label) {
                label.classList.add("bg-red-50", "dark:bg-red-900/50", "border-2", "border-red-500", "rounded-lg", "px-2", "py-1")
                label.classList.add("animate-shake")
                setTimeout(() => label.classList.remove("animate-shake"), 500)
              }
            } else if (group.type === 'button') {
              selectedItem.classList.remove('bg-blue-500', 'border-blue-500', 'text-white')
              selectedItem.classList.add("bg-red-50", "dark:bg-red-900/50", "border-red-500")
              selectedItem.classList.add("animate-shake")
              setTimeout(() => selectedItem.classList.remove("animate-shake"), 500)
            }

            // Highlight the correct answer in yellow
            group.items.forEach(item => {
              if (item.dataset.correctAnswer === "true") {
                if (group.type === 'radio') {
                  const correctLabel = item.closest('label')
                  if (correctLabel) {
                    correctLabel.classList.add("bg-yellow-50", "dark:bg-yellow-900/50", "border-2", "border-yellow-500", "rounded-lg", "px-2", "py-1")
                  }
                } else if (group.type === 'button') {
                  item.classList.add("bg-yellow-50", "dark:bg-yellow-900/50", "border-yellow-500")
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

    // Check select elements
    const selectElements = this.element.querySelectorAll("select[data-correct-answer]")
    if (selectElements.length > 0) {
      let selectCorrect = 0
      let selectIncorrect = 0
      let selectEmpty = 0

      selectElements.forEach(select => {
        const correctAnswer = select.dataset.correctAnswer.trim()
        const userAnswer = select.value.trim()

        // Remove all previous styling
        select.classList.remove("border-yellow-500", "border-green-500", "border-red-500",
                               "border-2", "border-4",
                               "bg-yellow-50", "bg-green-50", "bg-red-50",
                               "dark:bg-yellow-900/50", "dark:bg-green-900/50", "dark:bg-red-900/50")

        if (userAnswer === "" || userAnswer === "?") {
          selectEmpty++
          select.classList.add("border-yellow-500", "border-4", "bg-yellow-50", "dark:bg-yellow-900/50")
        } else if (userAnswer === correctAnswer) {
          selectCorrect++
          select.classList.add("border-green-500", "border-4", "bg-green-50", "dark:bg-green-900/50")
        } else {
          selectIncorrect++
          allCorrect = false
          select.classList.add("border-red-500", "border-4", "bg-red-50", "dark:bg-red-900/50")

          // Show shake animation
          select.classList.add("animate-shake")
          setTimeout(() => {
            select.classList.remove("animate-shake")
          }, 500)
        }
      })

      if (selectEmpty > 0) {
        allCorrect = false
        feedback.push(`Selezioni da completare: ${selectEmpty} ⚠️`)
      }
      if (selectCorrect > 0) {
        feedback.push(`Selezioni corrette: ${selectCorrect} ✅`)
      }
      if (selectIncorrect > 0) {
        feedback.push(`Selezioni errate: ${selectIncorrect} ❌`)
      }
    }

    // Check word-highlighter exercises
    const wordHighlighters = this.element.querySelectorAll("[data-controller*=\"word-highlighter\"]")
    if (wordHighlighters.length > 0) {
      wordHighlighters.forEach(highlighter => {
        const highlighterController = this.application.getControllerForElementAndIdentifier(highlighter, "word-highlighter")
        if (highlighterController && highlighterController.checkAnswers) {
          const result = highlighterController.checkAnswers()

          const totalToHighlight = result.totalToHighlight

          if (result.missedCount > 0) {
            allCorrect = false
            feedback.push(`Parole da evidenziare: ${result.missedCount} ⚠️`)
          }
          if (result.correctCount > 0 && totalToHighlight > 0) {
            feedback.push(`Parole evidenziate correttamente: ${result.correctCount - (result.totalWords - totalToHighlight)} ✅`)
          }
          if (result.incorrectCount > 0) {
            allCorrect = false
            feedback.push(`Parole evidenziate in modo errato: ${result.incorrectCount} ❌`)
          }
        }
      })
    }

    // Check syntagm-divider exercises
    const syntagmDividers = this.element.querySelectorAll("[data-controller*=\"syntagm-divider\"]")
    if (syntagmDividers.length > 0) {
      syntagmDividers.forEach(divider => {
        const dividerController = this.application.getControllerForElementAndIdentifier(divider, "syntagm-divider")
        if (dividerController && dividerController.checkAnswers) {
          const result = dividerController.checkAnswers()

          if (result) {
            if (result.correct < result.total) {
              allCorrect = false
              feedback.push(`Divisioni sintagmi: ${result.correct}/${result.total} corrette ${result.correct === result.total ? '✅' : '❌'}`)
            } else {
              feedback.push(`Divisioni sintagmi: ${result.correct}/${result.total} corrette ✅`)
            }
          }
        }
      })
    }

    // Check equivalent-fractions exercises
    const equivalentFractions = this.element.querySelectorAll("[data-controller*=\"equivalent-fractions\"]")
    if (equivalentFractions.length > 0) {
      equivalentFractions.forEach(fractionExercise => {
        const fractionController = this.application.getControllerForElementAndIdentifier(fractionExercise, "equivalent-fractions")
        if (fractionController && fractionController.checkAnswers) {
          // Create a fake event to pass to checkAnswers
          const fakeEvent = new Event('click')
          fakeEvent.preventDefault = () => {}
          fractionController.checkAnswers(fakeEvent)
          // Note: The controller will show its own feedback, so we don't need to add to our feedback array
          // We just let it run its validation
        }
      })
      // Don't show the standard feedback if equivalent-fractions is present
      // because it has its own feedback system
      return
    }

    // Check word-choice selections
    const wordChoiceGroups = this.element.querySelectorAll("[data-controller=\"word-choice\"]")
    if (wordChoiceGroups.length > 0) {
      let wordChoiceCorrect = 0
      let wordChoiceIncorrect = 0
      let wordChoiceEmpty = 0

      console.log(`Found ${wordChoiceGroups.length} word-choice groups`)

      wordChoiceGroups.forEach(wordChoiceGroup => {
        const words = wordChoiceGroup.querySelectorAll("[data-word-choice-target=\"word\"]")
        const groups = new Map()

        console.log(`  Found ${words.length} total words in this word-choice group`)

        // Group words by their group attribute
        words.forEach(word => {
          const groupName = word.dataset.group
          if (!groups.has(groupName)) {
            groups.set(groupName, [])
          }
          groups.get(groupName).push(word)
        })

        console.log(`  Organized into ${groups.size} choice groups`)

        // Check each group
        groups.forEach((groupWords, groupName) => {
          const selectedWord = groupWords.find(w => w.classList.contains('bg-pink-200'))

          console.log(`  Group ${groupName}: ${groupWords.length} words, selected word: ${selectedWord ? selectedWord.textContent.trim() : 'NONE'}`)

          // Remove previous styling (keep line-through from user selection)
          groupWords.forEach(w => {
            w.classList.remove('bg-green-100', 'bg-red-100', 'bg-yellow-100',
                              'dark:bg-green-900/60', 'dark:bg-red-900/60', 'dark:bg-yellow-900/60',
                              'border-2', 'border-green-500', 'border-red-500', 'border-yellow-500')
            // Don't remove line-through here - it's part of the user's selection state
          })

          if (!selectedWord) {
            wordChoiceEmpty++
            allCorrect = false
            // Highlight all words in group to show selection needed
            groupWords.forEach(w => {
              w.classList.add('bg-yellow-100', 'dark:bg-yellow-900/60', 'border-2', 'border-yellow-500')
            })
          } else {
            const isCorrect = selectedWord.dataset.correct === "true"

            if (isCorrect) {
              wordChoiceCorrect++
              selectedWord.classList.remove('bg-pink-200')
              selectedWord.classList.add('bg-green-100', 'dark:bg-green-900/60', 'border-2', 'border-green-500')

              // Remove line-through from non-selected words in correct answer groups
              groupWords.forEach(w => {
                if (w !== selectedWord) {
                  w.classList.remove('line-through', 'opacity-40', 'text-gray-500', 'cursor-not-allowed')
                }
              })
            } else {
              wordChoiceIncorrect++
              allCorrect = false
              selectedWord.classList.remove('bg-pink-200')
              selectedWord.classList.add('bg-red-100', 'dark:bg-red-900/60', 'border-2', 'border-red-500')
              selectedWord.classList.add('animate-shake')
              setTimeout(() => selectedWord.classList.remove('animate-shake'), 500)

              // Show correct answer
              const correctWord = groupWords.find(w => w.dataset.correct === "true")
              if (correctWord) {
                correctWord.classList.remove('line-through', 'opacity-40', 'text-gray-500', 'cursor-not-allowed')
                correctWord.classList.add('bg-yellow-100', 'dark:bg-yellow-900/60', 'border-2', 'border-yellow-500')
              }
            }
          }
        })
      })

      if (wordChoiceEmpty > 0) {
        allCorrect = false
        feedback.push(`Parole da selezionare: ${wordChoiceEmpty} ⚠️`)
      }
      if (wordChoiceCorrect > 0) {
        feedback.push(`Parole corrette: ${wordChoiceCorrect} ✅`)
      }
      if (wordChoiceIncorrect > 0) {
        feedback.push(`Parole errate: ${wordChoiceIncorrect} ❌`)
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

        // Check if this is a quaderno input
        const isQuadernoInput = input.hasAttribute('data-quaderno-addition-target') ||
            input.hasAttribute('data-quaderno-subtraction-target') ||
            input.hasAttribute('data-quaderno-multiplication-target') ||
            input.hasAttribute('data-quaderno-division-target')

        // For quaderno inputs: use simpler styling and handle empty cells correctly
        if (isQuadernoInput) {
          input.classList.remove('bg-transparent', 'bg-green-100', 'bg-red-100', 'bg-yellow-100',
                                 'dark:bg-green-900/50', 'dark:bg-red-900/50', 'dark:bg-yellow-900/50')

          // Cell should be empty
          if (correctAnswer === '') {
            if (userAnswer === '') {
              // Correct: cell is empty as expected
              input.classList.add('bg-transparent')
            } else {
              // Error: user entered something in a cell that should be empty
              input.classList.add('bg-red-100', 'dark:bg-red-900/50')
              inputsIncorrect++
              allCorrect = false
            }
            return
          }

          // Cell has a value
          if (userAnswer === '') {
            inputsEmpty++
            input.classList.add('bg-yellow-100', 'dark:bg-yellow-900/50')
          } else if (userAnswer === correctAnswer) {
            inputsCorrect++
            input.classList.add('bg-green-100', 'dark:bg-green-900/50')
          } else {
            inputsIncorrect++
            allCorrect = false
            input.classList.add('bg-red-100', 'dark:bg-red-900/50')
          }
          return
        }

        // Regular inputs (non-quaderno)
        // Remove all previous styling (including transparent backgrounds and borders)
        input.classList.remove("border-yellow-500", "border-green-500", "border-red-500",
                               "border-gray-300", "border-2", "border-4", "border-transparent",
                               "bg-yellow-50", "bg-green-50", "bg-red-50",
                               "bg-yellow-100", "bg-green-100", "bg-red-100",
                               "dark:bg-yellow-900/50", "dark:bg-green-900/50", "dark:bg-red-900/50",
                               "bg-white", "bg-white/60", "bg-white/80",
                               "text-black", "text-gray-900")

        if (userAnswer === "") {
          inputsEmpty++
          input.classList.add("border-yellow-500", "border-4", "bg-yellow-50", "dark:bg-yellow-900/50")
        } else if (userAnswer === correctAnswer) {
          inputsCorrect++
          input.classList.add("border-green-500", "border-4", "bg-green-50", "dark:bg-green-900/50")
        } else {
          inputsIncorrect++
          allCorrect = false
          input.classList.add("border-red-500", "border-4", "bg-red-50", "dark:bg-red-900/50")

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

    // Check quaderno multiplication comma positions
    const multiplicationControllers = this.element.querySelectorAll("[data-controller*=\"quaderno-multiplication\"]")
    if (multiplicationControllers.length > 0) {
      let commaCorrect = 0
      let commaIncorrect = 0
      let commaMissing = 0

      multiplicationControllers.forEach(mulElement => {
        const mulController = this.application.getControllerForElementAndIdentifier(mulElement, "quaderno-multiplication")
        if (mulController && mulController.hasCommaSpotTarget) {
          const commaSpots = mulController.commaSpotTargets
          let hasCorrectPosition = false
          let commaPlaced = false
          let placedInCorrectPosition = false

          commaSpots.forEach(spot => {
            const isCorrectPosition = spot.getAttribute('data-correct-position') === 'true'
            const isActive = spot.classList.contains('active')

            if (isCorrectPosition) {
              hasCorrectPosition = true
            }

            // Remove previous styling
            spot.classList.remove('correct', 'incorrect', 'missing')

            if (isActive) {
              commaPlaced = true
              if (isCorrectPosition) {
                spot.classList.add('correct')
                placedInCorrectPosition = true
              } else {
                spot.classList.add('incorrect')
              }
            }
          })

          // Count results for this controller
          if (hasCorrectPosition) {
            if (placedInCorrectPosition) {
              commaCorrect++
            } else if (commaPlaced) {
              commaIncorrect++
              allCorrect = false
            } else {
              commaMissing++
              allCorrect = false
              // Mark the correct position as missing
              commaSpots.forEach(spot => {
                if (spot.getAttribute('data-correct-position') === 'true') {
                  spot.classList.add('missing')
                }
              })
            }
          }
        }
      })

      if (commaMissing > 0) {
        feedback.push(`Virgole mancanti: ${commaMissing} ⚠️`)
      }
      if (commaCorrect > 0) {
        feedback.push(`Virgole corrette: ${commaCorrect} ✅`)
      }
      if (commaIncorrect > 0) {
        feedback.push(`Virgole errate: ${commaIncorrect} ❌`)
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
            option.classList.add("bg-red-100", "dark:bg-red-900/60", "border-2", "border-red-500", "rounded-lg")

            // Show shake animation
            option.classList.add("animate-shake")
            setTimeout(() => {
              option.classList.remove("animate-shake")
            }, 500)
          } else {
            // Highlight correct answer
            option.classList.add("bg-green-100", "dark:bg-green-900/60", "border-2", "border-green-500", "rounded-lg")
          }
        } else if (isCorrect) {
          // Show the correct answer if not selected
          groupCorrect = false
          option.classList.add("bg-yellow-100", "dark:bg-yellow-900/60", "border-2", "border-yellow-500", "rounded-lg")
          const correctHint = option.querySelector(".correct-hint")
          if (!correctHint) {
            const hint = document.createElement("span")
            hint.className = "correct-hint text-sm text-yellow-700 dark:text-yellow-300 ml-2 block mt-1"
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
    console.log(`Final feedback array before showing:`, feedback)
    console.log(`Final allCorrect status: ${allCorrect}`)
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
                            (allCorrect ? "bg-green-100 dark:bg-green-900/40 border-4 border-green-500" : "bg-orange-100 dark:bg-orange-900/40 border-4 border-orange-500")

    const title = document.createElement("h2")
    title.className = "text-2xl font-bold mb-4 " + (allCorrect ? "text-green-800 dark:text-green-200" : "text-orange-800 dark:text-orange-200")
    title.textContent = allCorrect ? "🎉 Eccellente! Tutte le risposte sono corrette!" : "📝 Controlla le risposte evidenziate"

    const messageList = document.createElement("ul")
    messageList.className = "space-y-2"

    messages.forEach(msg => {
      const li = document.createElement("li")
      li.className = "text-lg " + (allCorrect ? "text-green-700 dark:text-green-300" : "text-orange-700 dark:text-orange-300")
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

    // Launch confetti if all answers are correct
    if (allCorrect) {
      const jsConfetti = new JSConfetti()
      jsConfetti.addConfetti({
        confettiColors: [
          '#ff0a54', '#ff477e', '#ff7096', '#ff85a1', '#fbb1bd', '#f9bec7',
        ],
        emojis: ["❤️", "💙", "💜"],
        emojiSize: 25,
        confettiRadius: 5,
        confettiNumber: 400
      })
    }
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
          option.classList.add("bg-green-100", "dark:bg-green-900/60", "border-2", "border-green-500", "rounded-lg")

          // For exercise-group, show the checkmark
          if (!isCardGroup) {
            const checkmark = option.querySelector("[data-exercise-group-target=\"checkmark\"]")
            if (checkmark) {
              checkmark.classList.remove("hidden")
            }
          } else {
            // For card-selector, add the selection class
            option.classList.add("bg-orange-100", "dark:bg-orange-900/60")
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
            span.classList.add("border-green-500", "bg-green-100", "dark:bg-green-900/60")
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
              label.classList.add("bg-green-50", "dark:bg-green-900/50", "border-2", "border-green-500", "rounded-lg", "px-2", "py-1")
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
            button.classList.add("bg-green-50", "dark:bg-green-900/50", "border-green-500")
          }
        })
      })
    }

    // Fill in correct answers for select elements
    const selectElements = this.element.querySelectorAll("select[data-correct-answer]")
    selectElements.forEach(select => {
      const correctAnswer = select.dataset.correctAnswer.trim()
      select.value = correctAnswer
      select.classList.add("border-green-500", "border-4", "bg-green-50", "dark:bg-green-900/50")
    })

    // Fill in correct answers for text input fields
    const textInputFields = this.element.querySelectorAll("input[type='text'][data-correct-answer], textarea[data-correct-answer]")

    textInputFields.forEach(input => {
      const correctAnswer = input.dataset.correctAnswer.trim()

      // Check if this is a quaderno input
      const isQuadernoInput = input.hasAttribute('data-quaderno-addition-target') ||
          input.hasAttribute('data-quaderno-subtraction-target') ||
          input.hasAttribute('data-quaderno-multiplication-target') ||
          input.hasAttribute('data-quaderno-division-target')

      // For quaderno inputs: only fill non-empty values and use simpler styling
      if (isQuadernoInput) {
        if (correctAnswer !== '') {
          input.value = correctAnswer
          input.classList.remove('bg-transparent', 'bg-yellow-100', 'bg-red-100', 'dark:bg-yellow-900/50', 'dark:bg-red-900/50')
          input.classList.add('bg-green-100', 'dark:bg-green-900/50')
        }
        return
      }

      // Remove ALL background classes
      input.classList.remove("bg-transparent", "bg-white/60", "bg-white/80", "bg-white")

      input.value = correctAnswer

      // For textareas, also set textContent
      if (input.tagName === 'TEXTAREA') {
        input.textContent = correctAnswer
      }

      input.classList.add("border-green-500", "border-4", "bg-green-50", "dark:bg-green-900/50", "text-gray-900", "dark:text-white", "font-bold")
    })

    // Show correct answers for word-highlighter
    const wordHighlighters = this.element.querySelectorAll("[data-controller*=\"word-highlighter\"]")
    wordHighlighters.forEach(highlighter => {
      const highlighterController = this.application.getControllerForElementAndIdentifier(highlighter, "word-highlighter")
      if (highlighterController && highlighterController.showSolution) {
        highlighterController.showSolution()
      }
    })

    // Show correct answers for syntagm-divider
    const syntagmDividers = this.element.querySelectorAll("[data-controller*=\"syntagm-divider\"]")
    syntagmDividers.forEach(divider => {
      const dividerController = this.application.getControllerForElementAndIdentifier(divider, "syntagm-divider")
      if (dividerController && dividerController.showSolution) {
        dividerController.showSolution()
      }
    })

    // Show correct answers for word-choice
    const wordChoiceGroups = this.element.querySelectorAll("[data-controller=\"word-choice\"]")
    wordChoiceGroups.forEach(wordChoiceGroup => {
      const words = wordChoiceGroup.querySelectorAll("[data-word-choice-target=\"word\"]")

      words.forEach(word => {
        const isCorrect = word.dataset.correct === "true"

        if (isCorrect) {
          word.classList.remove('hover:bg-pink-100', 'line-through', 'opacity-40', 'text-gray-500', 'cursor-not-allowed')
          // Add both bg-pink-200 (for selection detection) and green styling (for visual feedback)
          word.classList.add('bg-pink-200', 'bg-green-100', 'dark:bg-green-900/60', 'border-2', 'border-green-500', 'font-bold', 'underline')
        } else {
          // Strike through incorrect words
          word.classList.remove('hover:bg-pink-100', 'bg-pink-200')
          word.classList.add('line-through', 'opacity-40', 'text-gray-500', 'dark:text-gray-400', 'cursor-not-allowed')
        }
      })
    })

    // Show sortable solutions if present
    const sortableControllers = this.element.querySelectorAll("[data-controller*=\"sortable\"]")
    sortableControllers.forEach(sortableElement => {
      const sortableController = this.application.getControllerForElementAndIdentifier(sortableElement, "sortable")
      if (sortableController && sortableController.showSolution) {
        sortableController.showSolution()
      }
    })

    // Show quaderno multiplication solutions (including comma position)
    const multiplicationControllers = this.element.querySelectorAll("[data-controller*=\"quaderno-multiplication\"]")
    multiplicationControllers.forEach(mulElement => {
      const mulController = this.application.getControllerForElementAndIdentifier(mulElement, "quaderno-multiplication")
      if (mulController && mulController.showResult) {
        mulController.showResult()
      }
    })

    // Show flower matcher solutions if present
    const flowerMatcher = this.element.querySelector("[data-controller=\"flower-matcher\"]")
    if (flowerMatcher) {
      const flowerController = this.application.getControllerForElementAndIdentifier(flowerMatcher, "flower-matcher")
      if (flowerController && flowerController.showSolutions) {
        flowerController.showSolutions()
      }
    }

    // Show equivalent-fractions solutions if present
    const equivalentFractions = this.element.querySelectorAll("[data-controller*=\"equivalent-fractions\"]")
    if (equivalentFractions.length > 0) {
      equivalentFractions.forEach(fractionExercise => {
        const fractionController = this.application.getControllerForElementAndIdentifier(fractionExercise, "equivalent-fractions")
        if (fractionController && fractionController.showSolutions) {
          const fakeEvent = new Event('click')
          fakeEvent.preventDefault = () => {}
          fractionController.showSolutions(fakeEvent)
        }
      })
      // Don't show standard feedback if equivalent-fractions has its own
      return
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
    feedbackDiv.className = "exercise-feedback my-6 p-6 rounded-lg shadow-lg bg-blue-100 dark:bg-blue-900/40 border-4 border-blue-500"

    const title = document.createElement("h2")
    title.className = "text-2xl font-bold mb-4 text-blue-800 dark:text-blue-200"
    title.textContent = "💡 Soluzioni mostrate!"

    const message = document.createElement("p")
    message.className = "text-lg text-blue-700 dark:text-blue-300"
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
                              "dark:bg-red-900/60", "dark:bg-green-900/60", "dark:bg-yellow-900/60",
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
                            "dark:bg-red-900/60", "dark:bg-green-900/60", "dark:bg-yellow-900/60",
                            "border-2", "border-red-500", "border-green-500",
                            "border-yellow-500", "bg-orange-100", "dark:bg-orange-900/60")
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
                                "bg-red-100", "bg-green-100", "bg-yellow-50",
                                "dark:bg-red-900/60", "dark:bg-green-900/60", "dark:bg-yellow-900/50")
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
                              "dark:bg-yellow-900/50", "dark:bg-green-900/50", "dark:bg-red-900/50",
                              "border-2", "border-yellow-500", "border-green-500", "border-red-500",
                              "rounded-lg", "px-2", "py-1")
      }
    })

    // Remove highlights from button-style answers
    const buttonAnswers = this.element.querySelectorAll('button[data-question][data-correct-answer]')
    buttonAnswers.forEach(button => {
      button.classList.remove("bg-blue-500", "bg-yellow-50", "bg-green-50", "bg-red-50",
                             "dark:bg-yellow-900/50", "dark:bg-green-900/50", "dark:bg-red-900/50",
                             "border-blue-500", "border-yellow-500", "border-green-500", "border-red-500", "text-white")
      button.classList.add("bg-transparent", "border-gray-300")
    })

    // Remove highlights from select elements and reset to default
    const selectElements = this.element.querySelectorAll("select[data-correct-answer]")
    selectElements.forEach(select => {
      select.classList.remove("border-yellow-500", "border-green-500", "border-red-500",
                             "border-4", "bg-yellow-50", "bg-green-50", "bg-red-50",
                             "dark:bg-yellow-900/50", "dark:bg-green-900/50", "dark:bg-red-900/50",
                             "border-2")
      select.value = ""
    })

    // Remove highlights from text input fields and restore original styling
    const textInputFields = this.element.querySelectorAll("input[type='text'][data-correct-answer], textarea[data-correct-answer]")
    textInputFields.forEach(input => {
      // Skip inputs that belong to quaderno controllers (they have their own reset)
      if (input.hasAttribute('data-quaderno-addition-target') ||
          input.hasAttribute('data-quaderno-subtraction-target') ||
          input.hasAttribute('data-quaderno-multiplication-target') ||
          input.hasAttribute('data-quaderno-division-target')) {
        return
      }

      input.classList.remove("border-yellow-500", "border-green-500", "border-red-500",
                             "border-4", "bg-yellow-50", "bg-green-50", "bg-red-50",
                             "dark:bg-yellow-900/50", "dark:bg-green-900/50", "dark:bg-red-900/50",
                             "border-gray-300", "border-gray-500", "border-2",
                             "text-gray-900", "dark:text-white", "font-bold")
      input.value = ""
    })

    // Remove highlights from word-highlighter
    const wordHighlighters = this.element.querySelectorAll("[data-controller*=\"word-highlighter\"]")
    wordHighlighters.forEach(highlighter => {
      const highlighterController = this.application.getControllerForElementAndIdentifier(highlighter, "word-highlighter")
      if (highlighterController && highlighterController.clearHighlights) {
        highlighterController.clearHighlights()
      }
    })

    // Clear syntagm-divider
    const syntagmDividers = this.element.querySelectorAll("[data-controller*=\"syntagm-divider\"]")
    syntagmDividers.forEach(divider => {
      const dividerController = this.application.getControllerForElementAndIdentifier(divider, "syntagm-divider")
      if (dividerController && dividerController.clearAll) {
        dividerController.clearAll()
      }
    })

    // Reset sortable exercises
    const sortableControllers = this.element.querySelectorAll("[data-controller*=\"sortable\"]")
    sortableControllers.forEach(sortableElement => {
      const sortableController = this.application.getControllerForElementAndIdentifier(sortableElement, "sortable")
      if (sortableController && sortableController.reset) {
        sortableController.reset()
      }
    })

    // Remove highlights from word-choice selections
    const wordChoiceWords = this.element.querySelectorAll("[data-word-choice-target=\"word\"]")
    wordChoiceWords.forEach(word => {
      word.classList.remove('bg-pink-200', 'bg-green-100', 'bg-red-100', 'bg-yellow-100',
                            'dark:bg-green-900/60', 'dark:bg-red-900/60', 'dark:bg-yellow-900/60',
                            'border-2', 'border-green-500', 'border-red-500', 'border-yellow-500',
                            'font-bold', 'underline', 'line-through', 'opacity-40', 'text-gray-500', 'dark:text-gray-400', 'cursor-not-allowed')
      word.classList.add('cursor-pointer', 'hover:bg-pink-100')
    })

    // Reset quaderno multiplication comma spots
    const multiplicationControllers = this.element.querySelectorAll("[data-controller*=\"quaderno-multiplication\"]")
    multiplicationControllers.forEach(mulElement => {
      const mulController = this.application.getControllerForElementAndIdentifier(mulElement, "quaderno-multiplication")
      if (mulController && mulController.hasCommaSpotTarget) {
        mulController.commaSpotTargets.forEach(spot => {
          spot.classList.remove('active', 'correct', 'incorrect', 'missing')
        })
      }
    })

    const feedback = this.element.querySelector(".exercise-feedback")
    if (feedback) feedback.remove()
  }
}
