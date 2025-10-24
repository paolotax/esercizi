import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audio-player"
export default class extends Controller {
  static values = {
    src: String
  }

  connect() {
    console.log("Audio player controller connected for:", this.srcValue)
  }

  play() {
    if (!this.srcValue) {
      console.warn("No audio source provided")
      return
    }

    // Create or reuse audio element
    if (!this.audio) {
      this.audio = new Audio(this.srcValue)
    }

    // Stop if already playing and restart
    if (!this.audio.paused) {
      this.audio.pause()
      this.audio.currentTime = 0
    }

    // Play the audio
    this.audio.play().catch(error => {
      console.error("Error playing audio:", error)
    })

    // Add visual feedback
    this.element.classList.add("scale-110")
    setTimeout(() => {
      this.element.classList.remove("scale-110")
    }, 200)
  }
}
