import { Controller } from "@hotwired/stimulus"
import JSConfetti from "js-confetti"

// Connects to data-controller="abaco"
export default class extends Controller {
  static targets = ["columnK", "columnH", "columnDa", "columnU", "ballK", "ballH", "ballDa", "ballU", "inputK", "inputH", "inputDa", "inputU", "totalValue", "totalInput", "feedback"]
  static values = {
    migliaia: { type: Number, default: 0 },
    centinaia: { type: Number, default: 0 },
    decine: { type: Number, default: 0 },
    unita: { type: Number, default: 0 },
    showH: { type: Boolean, default: false },
    showK: { type: Boolean, default: false },
    showDa: { type: Boolean, default: false },
    showU: { type: Boolean, default: false },
    max: { type: Number, default: 9 },
    editable: { type: Boolean, default: true },
    correct: { type: Number, default: null },
    mode: { type: String, default: "" } // "", "balls", "input"
  }

  connect() {
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
    // In mode "balls", le palline non sono cliccabili (l'utente deve solo scrivere il numero)
    if (this.modeValue === "balls") return

    const index = parseInt(event.currentTarget.dataset.index)
    this.migliaiaValue = index + 1  // k = migliaia (thousands)
    // In mode "input", non sincronizzare input (l'utente deve cliccare le palline senza vedere aggiornamenti)
    if (this.modeValue !== "input") {
      this.syncInputs()
    }
    this.updateDisplay()
    this.checkCorrectness()
  }

  clickBallH(event) {
    if (!this.editableValue) return
    if (this.modeValue === "balls") return

    const index = parseInt(event.currentTarget.dataset.index)
    this.centinaiaValue = index + 1  // h = centinaia (hundreds)
    if (this.modeValue !== "input") {
      this.syncInputs()
    }
    this.updateDisplay()
    this.checkCorrectness()
  }

  clickBallDa(event) {
    if (!this.editableValue) return
    if (this.modeValue === "balls") return

    const index = parseInt(event.currentTarget.dataset.index)
    this.decineValue = index + 1
    if (this.modeValue !== "input") {
      this.syncInputs()
    }
    this.updateDisplay()
    this.checkCorrectness()
  }

  clickBallU(event) {
    if (!this.editableValue) return
    if (this.modeValue === "balls") return

    const index = parseInt(event.currentTarget.dataset.index)
    this.unitaValue = index + 1
    if (this.modeValue !== "input") {
      this.syncInputs()
    }
    this.updateDisplay()
    this.checkCorrectness()
  }

  // Sincronizza gli input con i valori correnti (gestisce correttamente gli zeri)
  syncInputs() {
    // Determina quale colonna è la leftmost (più significativa)
    const leftmost = this.showKValue ? 'k' :  // k = migliaia (leftmost)
                    this.showHValue ? 'h' :    // h = centinaia
                    this.showDaValue ? 'da' :
                    this.showUValue ? 'u' : null

    // k: mostra solo se > 0, altrimenti vuoto (è sempre leftmost se presente)
    if (this.hasInputKTarget) {
      if (this.migliaiaValue > 0) {
        this.inputKTarget.value = this.migliaiaValue.toString()
      } else if (leftmost === 'k') {
        this.inputKTarget.value = ''
      } else if (this.showHValue && this.migliaiaValue > 0) {
        this.inputKTarget.value = '0'
      } else {
        this.inputKTarget.value = ''
      }
    }

    // h: mostra se > 0, OPPURE mostra "0" se non è leftmost e c'è valore a sinistra
    if (this.hasInputHTarget) {
      if (this.centinaiaValue > 0) {
        this.inputHTarget.value = this.centinaiaValue.toString()
      } else if (leftmost === 'h') {
        this.inputHTarget.value = ''
      } else if (this.showHValue && this.migliaiaValue > 0) {
        this.inputHTarget.value = '0'
      } else {
        this.inputHTarget.value = ''
      }
    }

    // da: mostra se > 0, OPPURE mostra "0" se non è leftmost e c'è valore a sinistra
    if (this.hasInputDaTarget) {
      if (this.decineValue > 0) {
        this.inputDaTarget.value = this.decineValue.toString()
      } else if (leftmost === 'da') {
        this.inputDaTarget.value = ''
      } else {
        const hasHigher = (this.showHValue && this.migliaiaValue > 0) || (this.showKValue && this.centinaiaValue > 0)
        this.inputDaTarget.value = hasHigher ? '0' : ''
      }
    }

    // u: mostra se > 0, OPPURE mostra "0" se non è leftmost e c'è valore a sinistra
    if (this.hasInputUTarget) {
      if (this.unitaValue > 0) {
        this.inputUTarget.value = this.unitaValue.toString()
      } else if (leftmost === 'u') {
        this.inputUTarget.value = ''
      } else {
        const hasHigher = (this.showHValue && this.migliaiaValue > 0) ||
                          (this.showKValue && this.centinaiaValue > 0) ||
                          (this.showDaValue && this.decineValue > 0)
        this.inputUTarget.value = hasHigher ? '0' : ''
      }
    }
  }

  // Pulsanti globali +/- (incrementano/decrementano il valore totale)
  incrementGlobal(event) {
    if (!this.editableValue) return

    // Incrementa dalla colonna più a destra visibile
    if (this.showUValue) {
      if (this.unitaValue < this.maxValue) {
        this.unitaValue++
      } else {
        this.unitaValue = 0
        // Carry a decine se visibili
        if (this.showDaValue) {
          if (this.decineValue < this.maxValue) {
            this.decineValue++
          } else {
            this.decineValue = 0
            // Carry a centinaia se visibili
            if (this.showKValue) {
              if (this.centinaiaValue < this.maxValue) {
                this.centinaiaValue++
              } else {
                this.centinaiaValue = 0
                // Carry a migliaia se visibili
                if (this.showHValue) {
                  if (this.migliaiaValue < this.maxValue) {
                    this.migliaiaValue++
                  } else {
                    this.migliaiaValue = 0 // Cicla
                  }
                }
                // else: cicla (centinaia è leftmost)
              }
            }
            // else: cicla (decine è leftmost)
          }
        }
        // else: cicla (unità è leftmost)
      }
    } else if (this.showDaValue) {
      // Incrementa decine (rightmost)
      if (this.decineValue < this.maxValue) {
        this.decineValue++
      } else {
        this.decineValue = 0
        if (this.showKValue) {
          if (this.centinaiaValue < this.maxValue) {
            this.centinaiaValue++
          } else {
            this.centinaiaValue = 0
            if (this.showHValue) {
              if (this.migliaiaValue < this.maxValue) {
                this.migliaiaValue++
              } else {
                this.migliaiaValue = 0
              }
            }
          }
        }
      }
    } else if (this.showKValue) {
      // Incrementa centinaia (rightmost)
      if (this.centinaiaValue < this.maxValue) {
        this.centinaiaValue++
      } else {
        this.centinaiaValue = 0
        if (this.showHValue) {
          if (this.migliaiaValue < this.maxValue) {
            this.migliaiaValue++
          } else {
            this.migliaiaValue = 0
          }
        }
      }
    } else if (this.showHValue) {
      // Incrementa migliaia (rightmost e leftmost)
      if (this.migliaiaValue < this.maxValue) {
        this.migliaiaValue++
      } else {
        this.migliaiaValue = 0
      }
    }

    this.syncInputs()
    this.updateDisplay()
    this.checkCorrectness()
  }

  decrementGlobal(event) {
    if (!this.editableValue) return

    // Decrementa dalla colonna più a destra visibile
    if (this.showUValue) {
      if (this.unitaValue > 0) {
        this.unitaValue--
      } else {
        this.unitaValue = this.maxValue
        // Borrow da decine se visibili
        if (this.showDaValue) {
          if (this.decineValue > 0) {
            this.decineValue--
          } else {
            this.decineValue = this.maxValue
            // Borrow da centinaia se visibili
            if (this.showKValue) {
              if (this.centinaiaValue > 0) {
                this.centinaiaValue--
              } else {
                this.centinaiaValue = this.maxValue
                // Borrow da migliaia se visibili
                if (this.showHValue) {
                  if (this.migliaiaValue > 0) {
                    this.migliaiaValue--
                  } else {
                    this.migliaiaValue = this.maxValue // Cicla
                  }
                }
                // else: cicla (centinaia è leftmost)
              }
            }
            // else: cicla (decine è leftmost)
          }
        }
        // else: cicla (unità è leftmost)
      }
    } else if (this.showDaValue) {
      // Decrementa decine (rightmost)
      if (this.decineValue > 0) {
        this.decineValue--
      } else {
        this.decineValue = this.maxValue
        if (this.showKValue) {
          if (this.centinaiaValue > 0) {
            this.centinaiaValue--
          } else {
            this.centinaiaValue = this.maxValue
            if (this.showHValue) {
              if (this.migliaiaValue > 0) {
                this.migliaiaValue--
              } else {
                this.migliaiaValue = this.maxValue
              }
            }
          }
        }
      }
    } else if (this.showKValue) {
      // Decrementa centinaia (rightmost)
      if (this.centinaiaValue > 0) {
        this.centinaiaValue--
      } else {
        this.centinaiaValue = this.maxValue
        if (this.showHValue) {
          if (this.migliaiaValue > 0) {
            this.migliaiaValue--
          } else {
            this.migliaiaValue = this.maxValue
          }
        }
      }
    } else if (this.showHValue) {
      // Decrementa migliaia (rightmost e leftmost)
      if (this.migliaiaValue > 0) {
        this.migliaiaValue--
      } else {
        this.migliaiaValue = this.maxValue
      }
    }

    this.syncInputs()
    this.updateDisplay()
    this.checkCorrectness()
  }

  // Pulsanti increment/decrement con riporto automatico (DEPRECATI - tenuti per compatibilità)
  // incrementK(event) {
  //   if (!this.editableValue) return

  //   if (this.centinaiaValue >= this.maxValue) {
  //     // Se siamo al massimo, torna a 0
  //     this.centinaiaValue = 0
  //     if (this.hasInputKTarget) {
  //       this.inputKTarget.value = ''
  //     }
  //   } else {
  //     this.centinaiaValue++
  //     if (this.hasInputKTarget) {
  //       this.inputKTarget.value = this.centinaiaValue.toString()
  //     }
  //   }
  //   this.updateDisplay()
  //   this.checkCorrectness()
  // }

  // decrementK(event) {
  //   if (!this.editableValue) return

  //   if (this.centinaiaValue <= 0) {
  //     // Da 0 (vuoto), vai al massimo (cicla)
  //     this.centinaiaValue = this.maxValue
  //     if (this.hasInputKTarget) {
  //       this.inputKTarget.value = this.centinaiaValue.toString()
  //     }
  //   } else if (this.centinaiaValue === 1) {
  //     // Da 1, diventa 0 vuoto (cifra più significativa)
  //     this.centinaiaValue = 0
  //     if (this.hasInputKTarget) {
  //       this.inputKTarget.value = ''
  //     }
  //   } else {
  //     // Altrimenti decrementa normalmente
  //     this.centinaiaValue--
  //     if (this.hasInputKTarget) {
  //       this.inputKTarget.value = this.centinaiaValue.toString()
  //     }
  //   }
  //   this.updateDisplay()
  //   this.checkCorrectness()
  // }

  // incrementDa(event) {
  //   if (!this.editableValue) return

  //   if (this.decineValue >= this.maxValue) {
  //     // Riporto: decine 9 → 0 (MOSTRATO!) e centinaia +1
  //     this.decineValue = 0
  //     if (this.hasInputDaTarget) {
  //       this.inputDaTarget.value = '0' // Mostra "0" non vuoto!
  //     }

  //     // Incrementa centinaia con riporto
  //     if (this.centinaiaValue >= this.maxValue) {
  //       // k cicla: 9 → vuoto
  //       this.centinaiaValue = 0
  //       if (this.hasInputKTarget) {
  //         this.inputKTarget.value = ''
  //       }
  //     } else {
  //       this.centinaiaValue++
  //       if (this.hasInputKTarget) {
  //         this.inputKTarget.value = this.centinaiaValue.toString()
  //       }
  //     }
  //   } else {
  //     this.decineValue++
  //     if (this.hasInputDaTarget) {
  //       this.inputDaTarget.value = this.decineValue.toString()
  //     }
  //   }
  //   this.updateDisplay()
  //   this.checkCorrectness()
  // }

  // decrementDa(event) {
  //   if (!this.editableValue) return

  //   if (this.decineValue === 0) {
  //     // Prestito: da 0 → 9 e centinaia -1
  //     this.decineValue = this.maxValue
  //     if (this.hasInputDaTarget) {
  //       this.inputDaTarget.value = this.decineValue.toString()
  //     }

  //     // Decrementa centinaia
  //     if (this.centinaiaValue > 1) {
  //       this.centinaiaValue--
  //       if (this.hasInputKTarget) {
  //         this.inputKTarget.value = this.centinaiaValue.toString()
  //       }
  //     } else if (this.centinaiaValue === 1) {
  //       // Da 1 a 0 vuoto
  //       this.centinaiaValue = 0
  //       if (this.hasInputKTarget) {
  //         this.inputKTarget.value = ''
  //       }
  //     } else {
  //       // Se centinaia è già 0 (vuoto), cicla a 9
  //       this.centinaiaValue = this.maxValue
  //       if (this.hasInputKTarget) {
  //         this.inputKTarget.value = this.centinaiaValue.toString()
  //       }
  //     }
  //   } else {
  //     // Decrementa normalmente: 5→4, 2→1, 1→0 (mostrato!)
  //     this.decineValue--
  //     if (this.hasInputDaTarget) {
  //       this.inputDaTarget.value = this.decineValue.toString() // Mostra anche "0"
  //     }
  //   }
  //   this.updateDisplay()
  //   this.checkCorrectness()
  // }

  // incrementU(event) {
  //   if (!this.editableValue) return

  //   if (this.unitaValue >= this.maxValue) {
  //     // Riporto: unità 9 → 0 (MOSTRATO!) e decine +1
  //     this.unitaValue = 0
  //     if (this.hasInputUTarget) {
  //       this.inputUTarget.value = '0' // Mostra "0" non vuoto!
  //     }

  //     // Incrementa decine con riporto
  //     if (this.decineValue >= this.maxValue) {
  //       // da: 9 → 0 (MOSTRATO!)
  //       this.decineValue = 0
  //       if (this.hasInputDaTarget) {
  //         this.inputDaTarget.value = '0' // Mostra "0" non vuoto!
  //       }

  //       // Incrementa centinaia
  //       if (this.centinaiaValue >= this.maxValue) {
  //         // k cicla: 9 → vuoto
  //         this.centinaiaValue = 0
  //         if (this.hasInputKTarget) {
  //           this.inputKTarget.value = ''
  //         }
  //       } else {
  //         this.centinaiaValue++
  //         if (this.hasInputKTarget) {
  //           this.inputKTarget.value = this.centinaiaValue.toString()
  //         }
  //       }
  //     } else {
  //       this.decineValue++
  //       if (this.hasInputDaTarget) {
  //         this.inputDaTarget.value = this.decineValue.toString()
  //       }
  //     }
  //   } else {
  //     this.unitaValue++
  //     if (this.hasInputUTarget) {
  //       this.inputUTarget.value = this.unitaValue.toString()
  //     }
  //   }
  //   this.updateDisplay()
  //   this.checkCorrectness()
  // }

  // decrementU(event) {
  //   if (!this.editableValue) return

  //   if (this.unitaValue === 0) {
  //     // Prestito: da 0 → 9 e decine -1
  //     this.unitaValue = this.maxValue
  //     if (this.hasInputUTarget) {
  //       this.inputUTarget.value = this.unitaValue.toString()
  //     }

  //     // Decrementa decine con prestito
  //     if (this.decineValue > 0) {
  //       this.decineValue--
  //       if (this.hasInputDaTarget) {
  //         this.inputDaTarget.value = this.decineValue.toString() // Mostra anche "0"
  //       }
  //     } else {
  //       // Decine è 0, prendi prestito da centinaia
  //       this.decineValue = this.maxValue
  //       if (this.hasInputDaTarget) {
  //         this.inputDaTarget.value = this.decineValue.toString()
  //       }

  //       if (this.centinaiaValue > 1) {
  //         this.centinaiaValue--
  //         if (this.hasInputKTarget) {
  //           this.inputKTarget.value = this.centinaiaValue.toString()
  //         }
  //       } else if (this.centinaiaValue === 1) {
  //         // Da 1 a 0 vuoto
  //         this.centinaiaValue = 0
  //         if (this.hasInputKTarget) {
  //           this.inputKTarget.value = ''
  //         }
  //       } else {
  //         // Se centinaia è già 0 (vuoto), cicla a 9
  //         this.centinaiaValue = this.maxValue
  //         if (this.hasInputKTarget) {
  //           this.inputKTarget.value = this.centinaiaValue.toString()
  //         }
  //       }
  //     }
  //   } else {
  //     // Decrementa normalmente: 5→4, 2→1, 1→0 (mostrato!)
  //     this.unitaValue--
  //     if (this.hasInputUTarget) {
  //       this.inputUTarget.value = this.unitaValue.toString() // Mostra anche "0"
  //     }
  //   }
  //   this.updateDisplay()
  //   this.checkCorrectness()
  // }

  // Update da input numerico
  updateFromInputK(event) {
    if (!this.editableValue) return
    // In mode "input", gli input sono readonly (l'utente deve solo cliccare le palline)
    if (this.modeValue === "input") return

    const input = event.target
    // Permetti solo numeri 0-9
    const cleanValue = input.value.replace(/[^0-9]/g, '')

    if (cleanValue === '') {
      // In mode "balls", NON modificare i valori delle palline - solo validare l'input
      if (this.modeValue !== "balls") {
        this.migliaiaValue = 0
      }
      input.value = ''
    } else {
      let value = parseInt(cleanValue)
      value = Math.min(Math.max(0, value), this.maxValue)
      // In mode "balls", NON modificare i valori delle palline
      if (this.modeValue !== "balls") {
        this.migliaiaValue = value
      }
      input.value = value.toString()
    }

    // In mode "balls", non aggiornare display (le palline sono fisse)
    if (this.modeValue !== "balls") {
      this.updateDisplay()
    }
    this.checkCorrectness()
  }

  updateFromInputH(event) {
    if (!this.editableValue) return
    if (this.modeValue === "input") return

    const input = event.target
    // Permetti solo numeri 0-9
    const cleanValue = input.value.replace(/[^0-9]/g, '')

    if (cleanValue === '') {
      if (this.modeValue !== "balls") {
        this.centinaiaValue = 0
      }
      input.value = ''
    } else {
      let value = parseInt(cleanValue)
      value = Math.min(Math.max(0, value), this.maxValue)
      if (this.modeValue !== "balls") {
        this.centinaiaValue = value
      }
      input.value = value.toString()
    }

    if (this.modeValue !== "balls") {
      this.updateDisplay()
    }
    this.checkCorrectness()
  }

  updateFromInputDa(event) {
    if (!this.editableValue) return
    if (this.modeValue === "input") return

    const input = event.target
    const cleanValue = input.value.replace(/[^0-9]/g, '')

    if (cleanValue === '') {
      if (this.modeValue !== "balls") {
        this.decineValue = 0
      }
      input.value = ''
    } else {
      let value = parseInt(cleanValue)
      value = Math.min(Math.max(0, value), this.maxValue)
      if (this.modeValue !== "balls") {
        this.decineValue = value
      }
      input.value = value.toString()
    }

    if (this.modeValue !== "balls") {
      this.updateDisplay()
    }
    this.checkCorrectness()
  }

  updateFromInputU(event) {
    if (!this.editableValue) return
    if (this.modeValue === "input") return

    const input = event.target
    const cleanValue = input.value.replace(/[^0-9]/g, '')

    if (cleanValue === '') {
      if (this.modeValue !== "balls") {
        this.unitaValue = 0
      }
      input.value = ''
    } else {
      let value = parseInt(cleanValue)
      value = Math.min(Math.max(0, value), this.maxValue)
      if (this.modeValue !== "balls") {
        this.unitaValue = value
      }
      input.value = value.toString()
    }

    if (this.modeValue !== "balls") {
      this.updateDisplay()
    }
    this.checkCorrectness()
  }

  updateDisplay() {
    // Aggiorna palline migliaia (viola) - K
    if (this.hasBallKTarget) {
      this.ballKTargets.forEach((ball, index) => {
        if (index < this.migliaiaValue) {
          ball.classList.remove("bg-transparent", "border-2", "border-dashed", "border-orange-200")
          ball.classList.add("bg-purple-500")
        } else {
          ball.classList.remove("bg-purple-500")
          ball.classList.add("bg-transparent", "border-2", "border-dashed", "border-orange-200")
        }
      })
    }

    // Aggiorna palline centinaia (verdi) - H
    if (this.hasBallHTarget) {
      this.ballHTargets.forEach((ball, index) => {
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
    const total = this.migliaiaValue * 1000 + this.centinaiaValue * 100 + this.decineValue * 10 + this.unitaValue

    if (this.hasTotalValueTarget) {
      this.totalValueTarget.textContent = total
    }

    // Aggiorna anche l'input nascosto se presente
    if (this.hasTotalInputTarget) {
      this.totalInputTarget.value = total
    }
  }

  checkCorrectness() {
    // Se non c'è correct_value, non c'è nulla da verificare
    if (this.correctValue === null) return

    // Calcola il totale attuale basandosi sulle colonne visibili (dalle palline/values interni)
    const currentBallsTotal = (this.showKValue ? this.migliaiaValue * 1000 : 0) +  // k = migliaia
                              (this.showHValue ? this.centinaiaValue * 100 : 0) +   // h = centinaia
                              (this.showDaValue ? this.decineValue * 10 : 0) +
                              (this.showUValue ? this.unitaValue : 0)

    // Calcola le cifre del valore corretto
    const correctK = Math.floor(this.correctValue / 1000) % 10  // k = migliaia
    const correctH = Math.floor(this.correctValue / 100) % 10   // h = centinaia
    const correctDa = Math.floor(this.correctValue / 10) % 10
    const correctU = this.correctValue % 10

    let isCorrect = false
    let allFieldsValid = true

    // Logica di verifica basata sul mode
    if (this.modeValue === "input") {
      // MODE INPUT: verifica solo le palline (l'utente clicca le palline per rappresentare il numero)
      // Le palline devono corrispondere al correct_value
      isCorrect = currentBallsTotal === this.correctValue
      allFieldsValid = true // Non verifichiamo gli input in questo mode
    } else if (this.modeValue === "balls") {
      // MODE BALLS: verifica solo gli input (l'utente vede le palline e deve inserire il numero)
      // Gli input devono corrispondere al correct_value

      if (this.showKValue && this.hasInputKTarget) {
        const inputVal = parseInt(this.inputKTarget.value) || 0
        if (correctK === 0) {
          allFieldsValid = allFieldsValid && (this.inputKTarget.value === '' || this.inputKTarget.value === '0')
        } else {
          allFieldsValid = allFieldsValid && this.inputKTarget.value !== ''
        }
      }

      if (this.showHValue && this.hasInputHTarget) {
        const inputVal = parseInt(this.inputHTarget.value) || 0
        if (correctH === 0) {
          allFieldsValid = allFieldsValid && (this.inputHTarget.value === '' || this.inputHTarget.value === '0')
        } else {
          allFieldsValid = allFieldsValid && this.inputHTarget.value !== ''
        }
      }

      if (this.showDaValue && this.hasInputDaTarget) {
        if (correctDa === 0) {
          allFieldsValid = allFieldsValid && (this.inputDaTarget.value === '' || this.inputDaTarget.value === '0')
        } else {
          allFieldsValid = allFieldsValid && this.inputDaTarget.value !== ''
        }
      }

      if (this.showUValue && this.hasInputUTarget) {
        if (correctU === 0) {
          allFieldsValid = allFieldsValid && (this.inputUTarget.value === '' || this.inputUTarget.value === '0')
        } else {
          allFieldsValid = allFieldsValid && this.inputUTarget.value !== ''
        }
      }

      // Calcola totale dagli input
      const inputK = this.hasInputKTarget ? (parseInt(this.inputKTarget.value) || 0) : 0
      const inputH = this.hasInputHTarget ? (parseInt(this.inputHTarget.value) || 0) : 0
      const inputDa = this.hasInputDaTarget ? (parseInt(this.inputDaTarget.value) || 0) : 0
      const inputU = this.hasInputUTarget ? (parseInt(this.inputUTarget.value) || 0) : 0
      const inputTotal = inputK * 1000 + inputH * 100 + inputDa * 10 + inputU

      isCorrect = allFieldsValid && inputTotal === this.correctValue
    } else {
      // MODE DEFAULT (sincronizzato): comportamento originale, verifica sia input che palline
      if (this.showKValue && this.hasInputKTarget) {
        if (correctK === 0) {
          allFieldsValid = allFieldsValid && (this.inputKTarget.value === '' || this.inputKTarget.value === '0')
        } else {
          allFieldsValid = allFieldsValid && this.inputKTarget.value !== ''
        }
      }

      if (this.showHValue && this.hasInputHTarget) {
        if (correctH === 0) {
          allFieldsValid = allFieldsValid && (this.inputHTarget.value === '' || this.inputHTarget.value === '0')
        } else {
          allFieldsValid = allFieldsValid && this.inputHTarget.value !== ''
        }
      }

      if (this.showDaValue && this.hasInputDaTarget) {
        if (correctDa === 0) {
          allFieldsValid = allFieldsValid && (this.inputDaTarget.value === '' || this.inputDaTarget.value === '0')
        } else {
          allFieldsValid = allFieldsValid && this.inputDaTarget.value !== ''
        }
      }

      if (this.showUValue && this.hasInputUTarget) {
        if (correctU === 0) {
          allFieldsValid = allFieldsValid && (this.inputUTarget.value === '' || this.inputUTarget.value === '0')
        } else {
          allFieldsValid = allFieldsValid && this.inputUTarget.value !== ''
        }
      }

      isCorrect = allFieldsValid && currentBallsTotal === this.correctValue
    }

    // Mostra feedback
    if (isCorrect) {
      // Lancia confetti (solo la prima volta)
      if (!this.hasCorrectAnswer) {
        this.confetti.addConfetti({
          confettiColors: ['#10b981', '#34d399', '#6ee7b7', '#a7f3d0', '#d1fae5'],
          confettiRadius: 6,
          confettiNumber: 200
        })
        this.hasCorrectAnswer = true
      }

      // Mostra feedback solo se il target esiste
      if (this.hasFeedbackTarget) {
        this.feedbackTarget.innerHTML = `
          <span class="inline-flex items-center gap-2 text-green-600 font-bold">
            <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
            </svg>
            Corretto!
          </span>
        `
      }
    } else {
      this.hasCorrectAnswer = false
      // Mostra "Riprova" solo se tutti i campi sono compilati ma sbagliati
      if (this.hasFeedbackTarget) {
        if (allFieldsValid) {
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
  }

  // Metodo pubblico per impostare un valore dall'esterno
  setValue(migliaia = 0, centinaia = 0, decine = 0, unita = 0) {
    // Supporta sia la nuova firma (4 parametri) che la vecchia (3 parametri)
    // Se migliaia è un oggetto, si aspetta { migliaia, centinaia, decine, unita }
    if (typeof migliaia === 'object') {
      const params = migliaia
      this.migliaiaValue = Math.min(Math.max(0, params.migliaia || 0), this.maxValue)
      this.centinaiaValue = Math.min(Math.max(0, params.centinaia || 0), this.maxValue)
      this.decineValue = Math.min(Math.max(0, params.decine || 0), this.maxValue)
      this.unitaValue = Math.min(Math.max(0, params.unita || 0), this.maxValue)
    } else if (arguments.length === 3) {
      // Retrocompatibilità: setValue(centinaia, decine, unita)
      this.migliaiaValue = 0
      this.centinaiaValue = Math.min(Math.max(0, migliaia), this.maxValue)
      this.decineValue = Math.min(Math.max(0, centinaia), this.maxValue)
      this.unitaValue = Math.min(Math.max(0, decine), this.maxValue)
    } else {
      // Nuova firma: setValue(migliaia, centinaia, decine, unita)
      this.migliaiaValue = Math.min(Math.max(0, migliaia), this.maxValue)
      this.centinaiaValue = Math.min(Math.max(0, centinaia), this.maxValue)
      this.decineValue = Math.min(Math.max(0, decine), this.maxValue)
      this.unitaValue = Math.min(Math.max(0, unita), this.maxValue)
    }

    // Sincronizza gli input con la logica corretta degli zeri
    this.syncInputs()

    this.updateDisplay()
    this.checkCorrectness()
  }

  // Metodo pubblico per ottenere il valore corrente
  getValue() {
    return this.migliaiaValue * 1000 + this.centinaiaValue * 100 + this.decineValue * 10 + this.unitaValue
  }
}
