import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="fraction-circles"
export default class extends Controller {
  static targets = ["slice", "circle", "feedback"]

  connect() {
    console.log("Fraction circles controller connected")
  }

  toggleSlice(event) {
    const slice = event.currentTarget
    const currentFill = slice.getAttribute('fill')

    if (currentFill === 'white' || currentFill === '#ffffff') {
      slice.setAttribute('fill', '#93C5FD') // blue-300
    } else {
      slice.setAttribute('fill', 'white')
    }
  }

  checkAnswers() {
    let allCorrect = true
    let results = []

    this.circleTargets.forEach((circle, index) => {
      const targetCount = parseInt(circle.dataset.target)
      const slices = circle.querySelectorAll('[data-fraction-circles-target="slice"]')
      const coloredCount = Array.from(slices).filter(slice => {
        const fill = slice.getAttribute('fill')
        return fill === '#93C5FD' || fill === 'rgb(147, 197, 253)'
      }).length

      if (coloredCount === targetCount) {
        results.push(`Cerchio ${index + 1}: ✅ Corretto!`)
        circle.classList.add('ring-4', 'ring-green-500', 'rounded-full')
        circle.classList.remove('ring-red-500', 'ring-yellow-500')
      } else if (coloredCount === 0) {
        results.push(`Cerchio ${index + 1}: ⚠️ Non hai colorato nessuno spicchio`)
        circle.classList.add('ring-4', 'ring-yellow-500', 'rounded-full')
        circle.classList.remove('ring-green-500', 'ring-red-500')
        allCorrect = false
      } else {
        results.push(`Cerchio ${index + 1}: ❌ Hai colorato ${coloredCount} spicchi invece di ${targetCount}`)
        circle.classList.add('ring-4', 'ring-red-500', 'rounded-full')
        circle.classList.remove('ring-green-500', 'ring-yellow-500')
        allCorrect = false
      }
    })

    this.showFeedback(results, allCorrect)
  }

  showSolutions() {
    this.circleTargets.forEach(circle => {
      const targetCount = parseInt(circle.dataset.target)
      const slices = circle.querySelectorAll('[data-fraction-circles-target="slice"]')

      // Reset tutti gli spicchi
      slices.forEach(slice => slice.setAttribute('fill', 'white'))

      // Colora il numero corretto di spicchi
      Array.from(slices).slice(0, targetCount).forEach(slice => {
        slice.setAttribute('fill', '#93C5FD')
      })

      // Aggiungi bordo verde
      circle.classList.add('ring-4', 'ring-green-500', 'rounded-full')
      circle.classList.remove('ring-red-500', 'ring-yellow-500')
    })

    this.showSolutionFeedback()
  }

  reset() {
    // Reset tutti gli spicchi
    this.sliceTargets.forEach(slice => {
      slice.setAttribute('fill', 'white')
    })

    // Rimuovi bordi colorati
    this.circleTargets.forEach(circle => {
      circle.classList.remove('ring-4', 'ring-green-500', 'ring-red-500', 'ring-yellow-500', 'rounded-full')
    })

    // Rimuovi feedback completamente
    if (this.hasFeedbackTarget) {
      this.feedbackTarget.innerHTML = ''
      this.feedbackTarget.className = ''
    }
  }

  showFeedback(messages, allCorrect) {
    if (!this.hasFeedbackTarget) return

    const feedbackDiv = this.feedbackTarget
    feedbackDiv.className = 'my-6 p-6 rounded-lg shadow-lg ' +
                           (allCorrect ? 'bg-green-100 border-4 border-green-500' : 'bg-orange-100 border-4 border-orange-500')

    const title = document.createElement('h3')
    title.className = 'text-2xl font-bold mb-4 ' + (allCorrect ? 'text-green-800' : 'text-orange-800')
    title.textContent = allCorrect ? '🎉 Perfetto! Tutte le frazioni sono corrette!' : '📝 Controlla i cerchi evidenziati'

    const messageList = document.createElement('ul')
    messageList.className = 'space-y-2'

    messages.forEach(msg => {
      const li = document.createElement('li')
      li.className = 'text-lg ' + (allCorrect ? 'text-green-700' : 'text-orange-700')
      li.textContent = msg
      messageList.appendChild(li)
    })

    feedbackDiv.innerHTML = ''
    feedbackDiv.appendChild(title)
    feedbackDiv.appendChild(messageList)

    feedbackDiv.scrollIntoView({ behavior: "smooth", block: "center" })
  }

  showSolutionFeedback() {
    if (!this.hasFeedbackTarget) return

    const feedbackDiv = this.feedbackTarget
    feedbackDiv.className = 'my-6 p-6 rounded-lg shadow-lg bg-blue-100 border-4 border-blue-500'

    feedbackDiv.innerHTML = `
      <h3 class="text-2xl font-bold mb-4 text-blue-800">💡 Soluzioni mostrate!</h3>
      <p class="text-lg text-blue-700">Tutti i cerchi mostrano il numero corretto di spicchi da colorare.</p>
    `

    feedbackDiv.scrollIntoView({ behavior: "smooth", block: "center" })
  }
}
