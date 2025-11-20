import { Controller } from "@hotwired/stimulus"
import JSConfetti from "js-confetti"

// Connects to data-controller="abaco"
export default class extends Controller {
  static targets = ["columnK", "columnDa", "columnU", "ballK", "ballDa", "ballU", "inputK", "inputDa", "inputU", "totalValue", "feedback"]
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
    this.confetti = new JSConfetti()
    this.updateDisplay()
  }

  disconnect() {
    if (this.confetti) {
      this.confetti.clearCanvas()
    }
  }

  // Click su una pallina specifica: setta il valore a index+1
  clickBallK(event) {
    if (!this.editableValue) return

    const index = parseInt(event.currentTarget.dataset.index)
    this.centinaiaValue = index + 1
    // Aggiorna anche l'input
    if (this.hasInputKTarget) {
      this.inputKTarget.value = this.centinaiaValue.toString()
    }
    this.updateDisplay()
    this.checkCorrectness()
  }

  clickBallDa(event) {
    if (!this.editableValue) return

    const index = parseInt(event.currentTarget.dataset.index)
    this.decineValue = index + 1
    // Aggiorna anche l'input
    if (this.hasInputDaTarget) {
      this.inputDaTarget.value = this.decineValue.toString()
    }
    this.updateDisplay()
    this.checkCorrectness()
  }

  clickBallU(event) {
    if (!this.editableValue) return

    const index = parseInt(event.currentTarget.dataset.index)
    this.unitaValue = index + 1
    // Aggiorna anche l'input
    if (this.hasInputUTarget) {
      this.inputUTarget.value = this.unitaValue.toString()
    }
    this.updateDisplay()
    this.checkCorrectness()
  }

  // Pulsanti globali +/- (incrementano/decrementano il valore totale)
  incrementGlobal(event) {
    if (!this.editableValue) return

    // Incrementa unità
    if (this.unitaValue < this.maxValue) {
      this.unitaValue++
    } else {
      // Riporto: u 9→0 e da +1
      this.unitaValue = 0

      if (this.decineValue < this.maxValue) {
        this.decineValue++
      } else {
        // Riporto: da 9→0 e k +1
        this.decineValue = 0

        if (this.centinaiaValue < this.maxValue) {
          this.centinaiaValue++
        } else {
          // Cicla: k 9→0 (tutti tornano a 000)
          this.centinaiaValue = 0
        }
      }
    }

    // Aggiorna input
    this.inputKTarget.value = this.centinaiaValue > 0 ? this.centinaiaValue.toString() : ''
    this.inputDaTarget.value = this.decineValue > 0 ? this.decineValue.toString() : (this.centinaiaValue > 0 ? '0' : '')
    this.inputUTarget.value = this.unitaValue > 0 ? this.unitaValue.toString() : ((this.centinaiaValue > 0 || this.decineValue > 0) ? '0' : '')

    this.updateDisplay()
    this.checkCorrectness()
  }

  decrementGlobal(event) {
    if (!this.editableValue) return

    // Decrementa unità
    if (this.unitaValue > 0) {
      this.unitaValue--
    } else {
      // Prestito: u 0→9 e da -1
      this.unitaValue = this.maxValue

      if (this.decineValue > 0) {
        this.decineValue--
      } else {
        // Prestito: da 0→9 e k -1
        this.decineValue = this.maxValue

        if (this.centinaiaValue > 0) {
          this.centinaiaValue--
        } else {
          // Cicla: 000 → 999
          this.centinaiaValue = this.maxValue
        }
      }
    }

    // Aggiorna input
    this.inputKTarget.value = this.centinaiaValue > 0 ? this.centinaiaValue.toString() : ''
    this.inputDaTarget.value = this.decineValue > 0 ? this.decineValue.toString() : (this.centinaiaValue > 0 ? '0' : '')
    this.inputUTarget.value = this.unitaValue > 0 ? this.unitaValue.toString() : ((this.centinaiaValue > 0 || this.decineValue > 0) ? '0' : '')

    this.updateDisplay()
    this.checkCorrectness()
  }

  // Pulsanti increment/decrement con riporto automatico (DEPRECATI - tenuti per compatibilità)
  incrementK(event) {
    if (!this.editableValue) return

    if (this.centinaiaValue >= this.maxValue) {
      // Se siamo al massimo, torna a 0
      this.centinaiaValue = 0
      if (this.hasInputKTarget) {
        this.inputKTarget.value = ''
      }
    } else {
      this.centinaiaValue++
      if (this.hasInputKTarget) {
        this.inputKTarget.value = this.centinaiaValue.toString()
      }
    }
    this.updateDisplay()
    this.checkCorrectness()
  }

  decrementK(event) {
    if (!this.editableValue) return

    if (this.centinaiaValue <= 0) {
      // Da 0 (vuoto), vai al massimo (cicla)
      this.centinaiaValue = this.maxValue
      if (this.hasInputKTarget) {
        this.inputKTarget.value = this.centinaiaValue.toString()
      }
    } else if (this.centinaiaValue === 1) {
      // Da 1, diventa 0 vuoto (cifra più significativa)
      this.centinaiaValue = 0
      if (this.hasInputKTarget) {
        this.inputKTarget.value = ''
      }
    } else {
      // Altrimenti decrementa normalmente
      this.centinaiaValue--
      if (this.hasInputKTarget) {
        this.inputKTarget.value = this.centinaiaValue.toString()
      }
    }
    this.updateDisplay()
    this.checkCorrectness()
  }

  incrementDa(event) {
    if (!this.editableValue) return

    if (this.decineValue >= this.maxValue) {
      // Riporto: decine 9 → 0 (MOSTRATO!) e centinaia +1
      this.decineValue = 0
      if (this.hasInputDaTarget) {
        this.inputDaTarget.value = '0' // Mostra "0" non vuoto!
      }

      // Incrementa centinaia con riporto
      if (this.centinaiaValue >= this.maxValue) {
        // k cicla: 9 → vuoto
        this.centinaiaValue = 0
        if (this.hasInputKTarget) {
          this.inputKTarget.value = ''
        }
      } else {
        this.centinaiaValue++
        if (this.hasInputKTarget) {
          this.inputKTarget.value = this.centinaiaValue.toString()
        }
      }
    } else {
      this.decineValue++
      if (this.hasInputDaTarget) {
        this.inputDaTarget.value = this.decineValue.toString()
      }
    }
    this.updateDisplay()
    this.checkCorrectness()
  }

  decrementDa(event) {
    if (!this.editableValue) return

    if (this.decineValue === 0) {
      // Prestito: da 0 → 9 e centinaia -1
      this.decineValue = this.maxValue
      if (this.hasInputDaTarget) {
        this.inputDaTarget.value = this.decineValue.toString()
      }

      // Decrementa centinaia
      if (this.centinaiaValue > 1) {
        this.centinaiaValue--
        if (this.hasInputKTarget) {
          this.inputKTarget.value = this.centinaiaValue.toString()
        }
      } else if (this.centinaiaValue === 1) {
        // Da 1 a 0 vuoto
        this.centinaiaValue = 0
        if (this.hasInputKTarget) {
          this.inputKTarget.value = ''
        }
      } else {
        // Se centinaia è già 0 (vuoto), cicla a 9
        this.centinaiaValue = this.maxValue
        if (this.hasInputKTarget) {
          this.inputKTarget.value = this.centinaiaValue.toString()
        }
      }
    } else {
      // Decrementa normalmente: 5→4, 2→1, 1→0 (mostrato!)
      this.decineValue--
      if (this.hasInputDaTarget) {
        this.inputDaTarget.value = this.decineValue.toString() // Mostra anche "0"
      }
    }
    this.updateDisplay()
    this.checkCorrectness()
  }

  incrementU(event) {
    if (!this.editableValue) return

    if (this.unitaValue >= this.maxValue) {
      // Riporto: unità 9 → 0 (MOSTRATO!) e decine +1
      this.unitaValue = 0
      if (this.hasInputUTarget) {
        this.inputUTarget.value = '0' // Mostra "0" non vuoto!
      }

      // Incrementa decine con riporto
      if (this.decineValue >= this.maxValue) {
        // da: 9 → 0 (MOSTRATO!)
        this.decineValue = 0
        if (this.hasInputDaTarget) {
          this.inputDaTarget.value = '0' // Mostra "0" non vuoto!
        }

        // Incrementa centinaia
        if (this.centinaiaValue >= this.maxValue) {
          // k cicla: 9 → vuoto
          this.centinaiaValue = 0
          if (this.hasInputKTarget) {
            this.inputKTarget.value = ''
          }
        } else {
          this.centinaiaValue++
          if (this.hasInputKTarget) {
            this.inputKTarget.value = this.centinaiaValue.toString()
          }
        }
      } else {
        this.decineValue++
        if (this.hasInputDaTarget) {
          this.inputDaTarget.value = this.decineValue.toString()
        }
      }
    } else {
      this.unitaValue++
      if (this.hasInputUTarget) {
        this.inputUTarget.value = this.unitaValue.toString()
      }
    }
    this.updateDisplay()
    this.checkCorrectness()
  }

  decrementU(event) {
    if (!this.editableValue) return

    if (this.unitaValue === 0) {
      // Prestito: da 0 → 9 e decine -1
      this.unitaValue = this.maxValue
      if (this.hasInputUTarget) {
        this.inputUTarget.value = this.unitaValue.toString()
      }

      // Decrementa decine con prestito
      if (this.decineValue > 0) {
        this.decineValue--
        if (this.hasInputDaTarget) {
          this.inputDaTarget.value = this.decineValue.toString() // Mostra anche "0"
        }
      } else {
        // Decine è 0, prendi prestito da centinaia
        this.decineValue = this.maxValue
        if (this.hasInputDaTarget) {
          this.inputDaTarget.value = this.decineValue.toString()
        }

        if (this.centinaiaValue > 1) {
          this.centinaiaValue--
          if (this.hasInputKTarget) {
            this.inputKTarget.value = this.centinaiaValue.toString()
          }
        } else if (this.centinaiaValue === 1) {
          // Da 1 a 0 vuoto
          this.centinaiaValue = 0
          if (this.hasInputKTarget) {
            this.inputKTarget.value = ''
          }
        } else {
          // Se centinaia è già 0 (vuoto), cicla a 9
          this.centinaiaValue = this.maxValue
          if (this.hasInputKTarget) {
            this.inputKTarget.value = this.centinaiaValue.toString()
          }
        }
      }
    } else {
      // Decrementa normalmente: 5→4, 2→1, 1→0 (mostrato!)
      this.unitaValue--
      if (this.hasInputUTarget) {
        this.inputUTarget.value = this.unitaValue.toString() // Mostra anche "0"
      }
    }
    this.updateDisplay()
    this.checkCorrectness()
  }

  // Update da input numerico
  updateFromInputK(event) {
    if (!this.editableValue) return

    const input = event.target
    // Permetti solo numeri 0-9
    const cleanValue = input.value.replace(/[^0-9]/g, '')

    if (cleanValue === '') {
      this.centinaiaValue = 0
      input.value = ''
    } else {
      let value = parseInt(cleanValue)
      value = Math.min(Math.max(0, value), this.maxValue)
      this.centinaiaValue = value
      input.value = value.toString() // Mantieni "0" se digitato
    }

    this.updateDisplay()
    this.checkCorrectness()
  }

  updateFromInputDa(event) {
    if (!this.editableValue) return

    const input = event.target
    const cleanValue = input.value.replace(/[^0-9]/g, '')

    if (cleanValue === '') {
      this.decineValue = 0
      input.value = ''
    } else {
      let value = parseInt(cleanValue)
      value = Math.min(Math.max(0, value), this.maxValue)
      this.decineValue = value
      input.value = value.toString() // Mantieni "0" se digitato
    }

    this.updateDisplay()
    this.checkCorrectness()
  }

  updateFromInputU(event) {
    if (!this.editableValue) return

    const input = event.target
    const cleanValue = input.value.replace(/[^0-9]/g, '')

    if (cleanValue === '') {
      this.unitaValue = 0
      input.value = ''
    } else {
      let value = parseInt(cleanValue)
      value = Math.min(Math.max(0, value), this.maxValue)
      this.unitaValue = value
      input.value = value.toString() // Mantieni "0" se digitato
    }

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
    if (this.hasBallDaTarget) {
      this.ballDaTargets.forEach((ball, index) => {
        if (index < this.decineValue) {
          ball.classList.remove("bg-transparent", "border-2", "border-dashed", "border-orange-200")
          ball.classList.add("bg-red-500")
        } else {
          ball.classList.remove("bg-red-500")
          ball.classList.add("bg-transparent", "border-2", "border-dashed", "border-orange-200")
        }
      })
    }

    // Aggiorna palline unità (blu)
    if (this.hasBallUTarget) {
      this.ballUTargets.forEach((ball, index) => {
        if (index < this.unitaValue) {
          ball.classList.remove("bg-transparent", "border-2", "border-dashed", "border-orange-200")
          ball.classList.add("bg-blue-500")
        } else {
          ball.classList.remove("bg-blue-500")
          ball.classList.add("bg-transparent", "border-2", "border-dashed", "border-orange-200")
        }
      })
    }

    // NON aggiornare gli input qui - sono gestiti nei metodi updateFromInput* e clickBall*
    // Questo previene il bug dove digitare "0" viene cancellato

    // Aggiorna valore totale
    if (this.hasTotalValueTarget) {
      const total = this.centinaiaValue * 100 + this.decineValue * 10 + this.unitaValue
      this.totalValueTarget.textContent = total
    }
  }

  checkCorrectness() {
    if (!this.hasFeedbackTarget || this.correctValue === null) return

    // Verifica che tutti gli input siano compilati (anche con "0")
    const allFieldsFilled =
      this.inputKTarget.value !== '' &&
      this.inputDaTarget.value !== '' &&
      this.inputUTarget.value !== ''

    const currentTotal = this.centinaiaValue * 100 + this.decineValue * 10 + this.unitaValue

    // Corretto solo se: tutti i campi compilati E valore corretto
    if (allFieldsFilled && currentTotal === this.correctValue) {
      // Lancia confetti (solo la prima volta)
      if (!this.hasCorrectAnswer) {
        this.confetti.addConfetti({
          confettiColors: ['#10b981', '#34d399', '#6ee7b7', '#a7f3d0', '#d1fae5'],
          confettiRadius: 6,
          confettiNumber: 200
        })
        this.hasCorrectAnswer = true
      }

      this.feedbackTarget.innerHTML = `
        <span class="inline-flex items-center gap-2 text-green-600 font-bold">
          <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
          </svg>
          Corretto!
        </span>
      `
    } else {
      this.hasCorrectAnswer = false
      // Mostra "Riprova" solo se tutti i campi sono compilati ma sbagliati
      if (allFieldsFilled) {
        this.feedbackTarget.innerHTML = `
          <span class="inline-flex items-center gap-2 text-orange-500 font-bold">
            <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
            </svg>
            Riprova
          </span>
        `
      } else {
        // Campi incompleti: nessun feedback
        this.feedbackTarget.innerHTML = ""
      }
    }
  }

  // Metodo pubblico per impostare un valore dall'esterno
  setValue(centinaia, decine, unita) {
    this.centinaiaValue = Math.min(Math.max(0, centinaia), this.maxValue)
    this.decineValue = Math.min(Math.max(0, decine), this.maxValue)
    this.unitaValue = Math.min(Math.max(0, unita), this.maxValue)

    // Aggiorna anche gli input
    if (this.hasInputKTarget) {
      this.inputKTarget.value = this.centinaiaValue > 0 ? this.centinaiaValue : ''
    }
    if (this.hasInputDaTarget) {
      this.inputDaTarget.value = this.decineValue > 0 ? this.decineValue : ''
    }
    if (this.hasInputUTarget) {
      this.inputUTarget.value = this.unitaValue > 0 ? this.unitaValue : ''
    }

    this.updateDisplay()
    this.checkCorrectness()
  }

  // Metodo pubblico per ottenere il valore corrente
  getValue() {
    return this.centinaiaValue * 100 + this.decineValue * 10 + this.unitaValue
  }
}
