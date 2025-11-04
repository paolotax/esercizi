import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    word: { type: String, default: "" },
    lang: { type: String, default: "it-IT" },
    rate: { type: Number, default: 1.0 },
    pitch: { type: Number, default: 1.0 },
    volume: { type: Number, default: 1.0 }
  }

  connect() {
    this.synthesis = window.speechSynthesis
    
    if (!this.synthesis) {
      console.warn("Speech synthesis not supported")
    }
  }

  async speak(event) {
    event.preventDefault()
    event.stopPropagation()
    
    if (!this.synthesis) {
      console.warn("Speech synthesis not available")
      return
    }

    // Get word from data attribute or value
    const word = this.wordValue || this.element.dataset.word || this.element.textContent.trim()
    
    if (!word || word.length === 0) {
      console.warn("No word to speak")
      return
    }

    // Stop any current speech
    this.synthesis.cancel()

    // Wait for voices to be loaded
    await this.waitForVoices()

    // Create utterance
    const utterance = new SpeechSynthesisUtterance(word)
    
    // Try to find an Italian voice
    const voices = this.synthesis.getVoices()
    const italianVoice = voices.find(voice => 
      voice.lang.startsWith('it') || 
      voice.name.toLowerCase().includes('italian') ||
      voice.name.toLowerCase().includes('italia')
    )
    
    if (italianVoice) {
      utterance.voice = italianVoice
    } else {
      utterance.lang = this.langValue
    }

    utterance.rate = this.rateValue
    utterance.pitch = this.pitchValue
    utterance.volume = this.volumeValue

    // Add visual feedback
    this.element.classList.add('animate-pulse', 'scale-110')
    setTimeout(() => {
      this.element.classList.remove('animate-pulse', 'scale-110')
    }, 500)

    // Speak
    this.synthesis.speak(utterance)
  }

  waitForVoices() {
    return new Promise((resolve) => {
      if (this.synthesis.getVoices().length > 0) {
        resolve()
      } else {
        // Force reload voices
        const dummyUtterance = new SpeechSynthesisUtterance('')
        this.synthesis.speak(dummyUtterance)
        this.synthesis.cancel()
        
        this.synthesis.onvoiceschanged = () => resolve()
        setTimeout(resolve, 1000)
      }
    })
  }
}

