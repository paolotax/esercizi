import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="abaco"
export default class extends Controller {
  static targets = ["columnK", "columnDa", "columnU", "ballK", "ballDa", "ballU", "labelK", "labelDa", "labelU", "totalValue", "feedback"]
  static values = {
    centinaia: { type: Number, default: 0 },
    decine: { type: Number, default: 0 },
    unita: { type: Number, default: 0 },
    max: { type: Number, default: 9 },
    editable: { type: Boolean, default: true },
    correct: { type: Number, default: null }
  }

  connect() {
    console.log("Abaco controller connected")
    this.updateDisplay()
  }

  toggleK(event) {
    if (!this.editableValue) return

    // Cicla: incrementa fino al max, poi torna a 0
    this.centinaiaValue = (this.centinaiaValue + 1) % (this.maxValue + 1)
    this.updateDisplay()
    this.checkCorrectness()
  }

  toggleDa(event) {
    if (!this.editableValue) return

    // Cicla: incrementa fino al max, poi torna a 0
    this.decineValue = (this.decineValue + 1) % (this.maxValue + 1)
    this.updateDisplay()
    this.checkCorrectness()
  }

  toggleU(event) {
    if (!this.editableValue) return

    // Cicla: incrementa fino al max, poi torna a 0
    this.unitaValue = (this.unitaValue + 1) % (this.maxValue + 1)
    this.updateDisplay()
    this.checkCorrectness()
  }

  updateDisplay() {
    // Aggiorna palline centinaia (verdi)
    if (this.hasBallKTarget) {
      this.ballKTargets.forEach((ball, index) => {
        if (index < this.centinaiaValue) {
          ball.classList.remove("bg-transparent", "border-2", "border-dashed", "border-orange-200")
          ball.classList.add("bg-green-500")
        } else {
          ball.classList.remove("bg-green-500")
          ball.classList.add("bg-transparent", "border-2", "border-dashed", "border-orange-200")
        }
      })
    }

    // Aggiorna palline decine (rosse)
    this.ballDaTargets.forEach((ball, index) => {
      if (index < this.decineValue) {
        ball.classList.remove("bg-transparent", "border-2", "border-dashed", "border-orange-200")
        ball.classList.add("bg-red-500")
      } else {
        ball.classList.remove("bg-red-500")
        ball.classList.add("bg-transparent", "border-2", "border-dashed", "border-orange-200")
      }
    })

    // Aggiorna palline unità (blu)
    this.ballUTargets.forEach((ball, index) => {
      if (index < this.unitaValue) {
        ball.classList.remove("bg-transparent", "border-2", "border-dashed", "border-orange-200")
        ball.classList.add("bg-blue-500")
      } else {
        ball.classList.remove("bg-blue-500")
        ball.classList.add("bg-transparent", "border-2", "border-dashed", "border-orange-200")
      }
    })

    // Aggiorna label
    if (this.hasLabelKTarget) {
      this.labelKTarget.textContent = this.centinaiaValue
    }
    if (this.hasLabelDaTarget) {
      this.labelDaTarget.textContent = this.decineValue
    }
    if (this.hasLabelUTarget) {
      this.labelUTarget.textContent = this.unitaValue
    }

    // Aggiorna valore totale
    if (this.hasTotalValueTarget) {
      const total = this.centinaiaValue * 100 + this.decineValue * 10 + this.unitaValue
      this.totalValueTarget.textContent = total
    }
  }

  checkCorrectness() {
    if (!this.hasFeedbackTarget || this.correctValue === null) return

    const currentTotal = this.centinaiaValue * 100 + this.decineValue * 10 + this.unitaValue

    if (currentTotal === this.correctValue) {
      this.feedbackTarget.innerHTML = `
        <span class="inline-flex items-center gap-2 text-green-600 font-bold">
          <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
          </svg>
          Corretto!
        </span>
      `
    } else if (currentTotal > 0) {
      this.feedbackTarget.innerHTML = `
        <span class="inline-flex items-center gap-2 text-orange-500 font-bold">
          <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
          </svg>
          Riprova
        </span>
      `
    } else {
      this.feedbackTarget.innerHTML = ""
    }
  }

  // Metodo pubblico per impostare un valore dall'esterno
  setValue(centinaia, decine, unita) {
    this.centinaiaValue = Math.min(Math.max(0, centinaia), this.maxValue)
    this.decineValue = Math.min(Math.max(0, decine), this.maxValue)
    this.unitaValue = Math.min(Math.max(0, unita), this.maxValue)
    this.updateDisplay()
    this.checkCorrectness()
  }

  // Metodo pubblico per ottenere il valore corrente
  getValue() {
    return this.centinaiaValue * 100 + this.decineValue * 10 + this.unitaValue
  }
}
