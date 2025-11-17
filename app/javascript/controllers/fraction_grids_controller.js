import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="fraction-grids"
export default class extends Controller {
  static targets = ["input", "cell", "feedback1", "feedback2", "feedback3"]

  connect() {
    console.log("Fraction grids controller connected")
  }

  toggleCell(event) {
    const cell = event.currentTarget
    if (cell.classList.contains('bg-white')) {
      cell.classList.remove('bg-white')
      cell.classList.add('bg-blue-300')
    } else {
      cell.classList.remove('bg-blue-300')
      cell.classList.add('bg-white')
    }
  }

  checkExercise1() {
    // Get first 36 inputs (esercizio 1: 3 celle * 2 input + 6 celle * 2 input + 9 celle * 2 input = 36)
    const allInputs = this.inputTargets
    const ex1Inputs = []

    // Count inputs before exercise 2
    let count = 0
    for (let i = 0; i < allInputs.length && count < 36; i++) {
      const input = allInputs[i]
      // Check if this input is in exercise 1 (has maxlength="1")
      if (input.maxLength === 1 && !input.closest('.text-center')?.querySelector('.text-4xl')) {
        ex1Inputs.push(input)
        count++
      }
    }

    let correct = 0
    let total = ex1Inputs.length

    ex1Inputs.forEach(input => {
      const answer = input.dataset.answer
      if (input.value.trim() === answer) {
        input.classList.remove('border-red-500', 'bg-red-50')
        input.classList.add('border-green-500', 'bg-green-50')
        correct++
      } else {
        input.classList.remove('border-green-500', 'bg-green-50')
        input.classList.add('border-red-500', 'bg-red-50')

        // Show shake animation
        input.classList.add('animate-shake')
        setTimeout(() => {
          input.classList.remove('animate-shake')
        }, 500)
      }
    })

    if (correct === total) {
      this.feedback1Target.innerHTML = '<span class="text-green-600">✓ Perfetto! Tutte le risposte sono corrette!</span>'
    } else {
      this.feedback1Target.innerHTML = `<span class="text-orange-600">Hai completato ${correct} su ${total}. Riprova!</span>`
    }

    // Scroll to feedback
    this.feedback1Target.scrollIntoView({ behavior: "smooth", block: "center" })
  }

  checkExercise2() {
    // Get inputs from exercise 2 (the ones with justify-center parent)
    const allInputs = this.inputTargets
    const ex2Inputs = []

    allInputs.forEach(input => {
      // Check if input is in a flex container with justify-center (exercise 2 pattern)
      const parent = input.closest('.flex.items-center.justify-center')
      if (parent && input.maxLength === 1) {
        // Exclude exercise 1 inputs by checking if they're in the large grid structure
        const gridParent = input.closest('.flex.gap-0')
        if (!gridParent || gridParent.querySelectorAll('.w-24.h-24').length === 0) {
          ex2Inputs.push(input)
        }
      }
    })

    let correct = 0
    let total = ex2Inputs.length

    ex2Inputs.forEach(input => {
      const answer = input.dataset.answer
      if (input.value.trim() === answer) {
        input.classList.remove('border-red-500', 'bg-red-50')
        input.classList.add('border-green-500', 'bg-green-50')
        correct++
      } else {
        input.classList.remove('border-green-500', 'bg-green-50')
        input.classList.add('border-red-500', 'bg-red-50')

        // Show shake animation
        input.classList.add('animate-shake')
        setTimeout(() => {
          input.classList.remove('animate-shake')
        }, 500)
      }
    })

    if (correct === total) {
      this.feedback2Target.innerHTML = '<span class="text-green-600">✓ Fantastico! Hai completato correttamente le progressioni!</span>'
    } else {
      this.feedback2Target.innerHTML = `<span class="text-orange-600">Hai completato ${correct} su ${total}. Riprova!</span>`
    }

    // Scroll to feedback
    this.feedback2Target.scrollIntoView({ behavior: "smooth", block: "center" })
  }

  checkExercise3() {
    // Get inputs from exercise 3 (in the green gradient container)
    const allInputs = this.inputTargets
    const ex3Inputs = []

    allInputs.forEach(input => {
      // Check if input is in the exercise 3 container (has w-16 h-12 classes)
      if (input.classList.contains('w-16') && input.classList.contains('h-12')) {
        ex3Inputs.push(input)
      }
    })

    let correct = 0
    let total = ex3Inputs.length

    ex3Inputs.forEach(input => {
      const answer = input.dataset.answer
      if (input.value.trim() === answer) {
        input.classList.remove('border-red-500', 'bg-red-50', 'border-orange-300')
        input.classList.add('border-green-500', 'bg-green-50')
        correct++
      } else {
        input.classList.remove('border-green-500', 'bg-green-50', 'border-orange-300')
        input.classList.add('border-red-500', 'bg-red-50')

        // Show shake animation
        input.classList.add('animate-shake')
        setTimeout(() => {
          input.classList.remove('animate-shake')
        }, 500)
      }
    })

    if (correct === total) {
      this.feedback3Target.innerHTML = '<span class="text-green-600">✓ Ottimo! Hai capito come funzionano le frazioni con i bicchieri!</span>'
    } else {
      this.feedback3Target.innerHTML = `<span class="text-orange-600">Hai completato ${correct} su ${total}. Riprova!</span>`
    }

    // Scroll to feedback
    this.feedback3Target.scrollIntoView({ behavior: "smooth", block: "center" })
  }
}
