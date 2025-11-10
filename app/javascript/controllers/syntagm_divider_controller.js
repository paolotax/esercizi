import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="syntagm-divider"
export default class extends Controller {
  static targets = ["divider"]

  connect() {
    console.log("Syntagm divider controller connected")
  }

  toggleDivider(event) {
    const divider = event.currentTarget
    const slashElement = divider.querySelector('.slash')

    if (slashElement) {
      // Remove the slash
      slashElement.remove()
      divider.classList.remove('has-divider')
    } else {
      // Add the slash
      const slash = document.createElement('span')
      slash.className = 'slash text-blue-600 font-bold mx-1'
      slash.textContent = '/'
      divider.appendChild(slash)
      divider.classList.add('has-divider')
    }

    // Visual feedback
    divider.classList.add('animate-pulse')
    setTimeout(() => {
      divider.classList.remove('animate-pulse')
    }, 200)
  }

  checkAnswers() {
    let correct = 0
    let total = 0

    this.dividerTargets.forEach(divider => {
      const hasSlash = divider.classList.contains('has-divider')
      const shouldHaveSlash = divider.dataset.correct === 'true'

      total++

      if (hasSlash === shouldHaveSlash) {
        correct++
        // Mark as correct
        divider.classList.remove('bg-red-100', 'border-red-300')
        divider.classList.add('bg-green-100', 'border-green-300')
      } else {
        // Mark as incorrect
        divider.classList.remove('bg-green-100', 'border-green-300')
        divider.classList.add('bg-red-100', 'border-red-300')
      }
    })

    // Show feedback
    const percentage = Math.round((correct / total) * 100)
    let message = `Hai indovinato ${correct} su ${total} divisioni (${percentage}%)`

    if (percentage === 100) {
      message += " 🎉 Perfetto!"
      this.showNotification(message, 'success')
    } else if (percentage >= 70) {
      message += " 👍 Bravo!"
      this.showNotification(message, 'warning')
    } else {
      message += " 💪 Riprova!"
      this.showNotification(message, 'error')
    }
  }

  clearAll() {
    this.dividerTargets.forEach(divider => {
      const slashElement = divider.querySelector('.slash')
      if (slashElement) {
        slashElement.remove()
      }
      divider.classList.remove('has-divider', 'bg-green-100', 'bg-red-100', 'border-green-300', 'border-red-300')
    })
  }

  showNotification(message, type) {
    // Create notification element
    const notification = document.createElement('div')
    notification.className = `fixed top-4 right-4 px-6 py-4 rounded-lg shadow-lg z-50 animate-bounce ${
      type === 'success' ? 'bg-green-500' :
      type === 'warning' ? 'bg-yellow-500' :
      'bg-red-500'
    } text-white font-semibold`
    notification.textContent = message

    document.body.appendChild(notification)

    // Remove after 3 seconds
    setTimeout(() => {
      notification.classList.add('animate-fade-out')
      setTimeout(() => notification.remove(), 300)
    }, 3000)
  }
}
