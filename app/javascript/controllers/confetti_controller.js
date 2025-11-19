import { Controller } from "@hotwired/stimulus"
import JSConfetti from "js-confetti"



// Connects to data-controller="confetti"
export default class extends Controller {
  connect() {
    this.confetti = new JSConfetti()
  }


  launch() {
    this.confetti.addConfetti({
      confettiColors: [
        '#ff0a54', '#ff477e', '#ff7096', '#ff85a1', '#fbb1bd', '#f9bec7',
      ],
      emojis: ["❤️", "💙", "💜"],
      emojiSize: 30,
      confettiRadius: 5,
      confettiNumber: 400
    })
  }

  disconnect() {
    if (this.confetti) {
      this.confetti.clearCanvas()
    }
  }
}
