import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textContent", "button"]
  static values = {
    lang: { type: String, default: "it-IT" },
    rate: { type: Number, default: 0.9 },
    pitch: { type: Number, default: 1.1 },
    volume: { type: Number, default: 1.0 }
  }

  connect() {
    this.synthesis = window.speechSynthesis
    this.isSpeaking = false
    this.currentUtterance = null
    this.wordSpans = []
    this.currentWordIndex = 0
    this.originalText = null
    this.highlightInterval = null
    this.startTime = null
    this.estimatedDuration = null
    this.lastBoundaryUpdate = null
    this.textMapping = null
    this.originalTextForMapping = null
    
    // Check if browser supports speech synthesis
    if (!this.synthesis) {
      console.warn("Speech synthesis not supported in this browser")
      this.disableButton("Sintesi vocale non supportata")
    } else {
      // Preload voices on connect
      this.waitForVoices().catch(err => {
        console.warn("Could not load voices:", err)
      })
    }
  }

  disconnect() {
    this.stop()
  }

  async read() {
    // Check if browser supports speech synthesis
    if (!this.synthesis) {
      alert("⚠️ La sintesi vocale non è supportata dal tuo browser.\n\nProva con Google Chrome o verifica che Chromium abbia la Web Speech API abilitata.")
      return
    }

    // Check if SpeechSynthesisUtterance is available
    if (typeof SpeechSynthesisUtterance === 'undefined') {
      alert("⚠️ La sintesi vocale non è disponibile nel tuo browser.\n\nProva con Google Chrome o un altro browser moderno.")
      return
    }

    // If already speaking, stop first
    if (this.isSpeaking) {
      this.stop()
      return
    }

    // Get text content from the target
    const textElement = this.textContentTarget
    if (!textElement) {
      console.error("Text content target not found")
      alert("Errore: non è stato trovato il testo da leggere.")
      return
    }

    // Store original text for highlighting
    this.originalText = textElement

    // Extract text, excluding line numbers and formatting
    const text = this.extractTextContent(textElement)
    
    if (!text || text.trim().length === 0) {
      alert("Nessun testo da leggere.")
      return
    }

    console.log("Testo estratto:", text.substring(0, 100) + "...")

    // Store original text for mapping (without pauses)
    this.originalTextForMapping = text

    // Prepare text for highlighting (wrap words in spans)
    this.prepareTextForHighlighting(textElement, text)

    try {
      // Wait for voices to be loaded with timeout
      await Promise.race([
        this.waitForVoices(),
        new Promise((_, reject) => setTimeout(() => reject(new Error("Timeout")), 3000))
      ])
    } catch (error) {
      console.warn("Could not load voices, using default:", error)
      // Continue anyway with default language
    }

    // Create utterance with expressive reading settings
    const utterance = new SpeechSynthesisUtterance(text)
    
    // Try to find an Italian voice
    const voices = this.synthesis.getVoices()
    console.log("Voci disponibili:", voices.length)
    
    if (voices.length > 0) {
      const italianVoice = voices.find(voice => 
        voice.lang.startsWith('it') || 
        voice.name.toLowerCase().includes('italian') ||
        voice.name.toLowerCase().includes('italia')
      )
      
      if (italianVoice) {
        utterance.voice = italianVoice
        console.log("Voce italiana trovata:", italianVoice.name)
      } else {
        // Try to use any available voice with Italian language
        const itVoices = voices.filter(v => v.lang.startsWith('it'))
        if (itVoices.length > 0) {
          utterance.voice = itVoices[0]
          console.log("Voce italiana trovata:", itVoices[0].name)
        } else {
          utterance.lang = this.langValue
          console.log("Usando lingua predefinita:", this.langValue)
        }
      }
    } else {
      utterance.lang = this.langValue
      console.log("Nessuna voce disponibile, usando lingua predefinita")
    }

    // Expressive reading settings
    utterance.rate = this.rateValue    // Slightly slower for expressive reading
    utterance.pitch = this.pitchValue  // Slightly higher pitch for more expression
    utterance.volume = this.volumeValue

    // Store text with pauses for mapping
    const textWithPauses = this.addPauses(text)
    utterance.text = textWithPauses
    
    // Create mapping between text with pauses and original text
    this.createTextMapping(text, textWithPauses)

    // Event handlers
    utterance.onstart = () => {
      console.log("Lettura iniziata")
      this.isSpeaking = true
      this.currentWordIndex = 0
      this.startTime = Date.now()
      this.highlightWord(0)
      this.updateButtonState(true)
      
      // Start fallback highlighting if boundary events don't work
      this.startFallbackHighlighting()
    }

    utterance.onboundary = (event) => {
      // Event triggered when speech reaches a word boundary
      // Use this as a secondary check to keep timing accurate
      if (event.name === 'word' && event.charIndex !== undefined) {
        const charIndex = event.charIndex
        const wordIndex = this.getWordIndexFromCharIndex(charIndex)
        
        if (wordIndex !== -1 && wordIndex < this.wordSpans.length && wordIndex >= 0) {
          this.lastBoundaryUpdate = Date.now()
          
          // Only update if we're significantly behind (more than 2 words)
          // This prevents conflicts with the timing-based highlighting
          if (Math.abs(wordIndex - this.currentWordIndex) > 2) {
            this.highlightWord(wordIndex)
            console.log(`Boundary sync: charIndex=${charIndex}, wordIndex=${wordIndex}, correcting from ${this.currentWordIndex}`)
          }
        }
      }
    }

    utterance.onend = () => {
      console.log("Lettura completata")
      this.isSpeaking = false
      this.currentUtterance = null
      this.stopFallbackHighlighting()
      this.removeAllHighlights()
      this.updateButtonState(false)
    }

    utterance.onerror = (event) => {
      console.error("Errore sintesi vocale:", event)
      let errorMsg = "Errore durante la lettura."
      
      if (event.error === 'not-allowed') {
        errorMsg = "Permesso negato. Verifica le impostazioni del browser."
      } else if (event.error === 'network') {
        errorMsg = "Errore di rete. Verifica la connessione."
      } else if (event.error === 'synthesis-failed') {
        errorMsg = "La sintesi vocale non è disponibile. Prova con Google Chrome."
      }
      
      alert(`⚠️ ${errorMsg}`)
      this.isSpeaking = false
      this.currentUtterance = null
      this.updateButtonState(false)
    }

    // Speak - try to start speaking
    try {
      this.currentUtterance = utterance
      this.synthesis.speak(utterance)
      
      // Check if speaking actually started (some browsers need user interaction)
      setTimeout(() => {
        if (!this.synthesis.speaking && !this.isSpeaking) {
          console.warn("La lettura non è iniziata. Potrebbe essere necessario un'interazione utente.")
          alert("⚠️ La lettura non è iniziata.\n\nSu alcuni browser è necessario un'interazione utente prima della prima lettura. Riprova cliccando di nuovo il pulsante.")
        }
      }, 500)
    } catch (error) {
      console.error("Errore nell'avvio della sintesi vocale:", error)
      alert(`⚠️ Errore: ${error.message}\n\nProva con Google Chrome se il problema persiste.`)
    }
  }

  stop() {
    if (this.synthesis && this.isSpeaking) {
      this.synthesis.cancel()
      this.isSpeaking = false
      this.currentUtterance = null
      this.stopFallbackHighlighting()
      this.removeAllHighlights()
      this.updateButtonState(false)
    }
  }

  pause() {
    if (this.synthesis && this.isSpeaking) {
      this.synthesis.pause()
    }
  }

  resume() {
    if (this.synthesis && this.synthesis.paused) {
      this.synthesis.resume()
    }
  }

  extractTextContent(element) {
    // Clone the element to avoid modifying the original
    const clone = element.cloneNode(true)
    
    // Remove line numbers (spans with orange text and numbers)
    const lineNumbers = clone.querySelectorAll('span.text-orange-500')
    lineNumbers.forEach(span => span.remove())
    
    // Remove page numbers and other UI elements
    const pageNumbers = clone.querySelectorAll('.absolute, [class*="bg-red-600"], [class*="bg-red-500"]')
    pageNumbers.forEach(el => el.remove())
    
    // Remove header elements
    const headers = clone.querySelectorAll('h2, h3, [class*="HO IMPARATO"]')
    headers.forEach(el => el.remove())
    
    // Get all text from paragraphs in the story section
    const storySection = clone.querySelector('.rounded-lg.p-4, .rounded-lg.p-6') || clone
    const paragraphs = storySection.querySelectorAll('p.text-gray-800')
    
    if (paragraphs.length === 0) {
      // Fallback: get all paragraphs
      const allParagraphs = clone.querySelectorAll('p')
      const textParts = Array.from(allParagraphs).map(p => {
        let text = p.textContent.trim()
        // Remove any remaining numbers at the start
        text = text.replace(/^\d+\s*/, '')
        return text
      }).filter(text => text.length > 0)
      return textParts.join('. ')
    }
    
    const textParts = Array.from(paragraphs).map(p => {
      let text = p.textContent.trim()
      // Remove any remaining numbers at the start
      text = text.replace(/^\d+\s*/, '')
      return text
    }).filter(text => text.length > 0)
    
    // Join with appropriate pauses
    return textParts.join('. ')
  }

  addPauses(text) {
    // Add longer pauses for better expression
    // At end of sentences: longer pause
    text = text.replace(/([.!?])\s+/g, '$1 ... ')
    // At commas: shorter pause
    text = text.replace(/,/g, ', ')
    // At dashes: medium pause
    text = text.replace(/–/g, ' – ')
    return text
  }

  updateButtonState(speaking) {
    if (this.hasButtonTarget) {
      const button = this.buttonTarget
      // Find the text span (it has class "hidden md:inline")
      const textSpan = Array.from(button.querySelectorAll('span')).find(span => 
        span.classList.contains('hidden')
      )
      
      if (speaking) {
        button.classList.remove('bg-blue-500', 'hover:bg-blue-600')
        button.classList.add('bg-red-500', 'hover:bg-red-600')
        if (textSpan) textSpan.textContent = 'Ferma'
      } else {
        button.classList.remove('bg-red-500', 'hover:bg-red-600')
        button.classList.add('bg-blue-500', 'hover:bg-blue-600')
        if (textSpan) textSpan.textContent = 'Leggi'
      }
    }
  }

  waitForVoices() {
    return new Promise((resolve) => {
      // Force reload voices on Chromium
      if (this.synthesis.getVoices().length === 0) {
        // Some browsers need this to load voices
        const dummyUtterance = new SpeechSynthesisUtterance('')
        this.synthesis.speak(dummyUtterance)
        this.synthesis.cancel()
      }
      
      if (this.synthesis.getVoices().length > 0) {
        resolve()
      } else {
        // Try multiple times
        let attempts = 0
        const maxAttempts = 10
        
        const checkVoices = () => {
          attempts++
          const voices = this.synthesis.getVoices()
          if (voices.length > 0 || attempts >= maxAttempts) {
            resolve()
          } else {
            setTimeout(checkVoices, 100)
          }
        }
        
        this.synthesis.onvoiceschanged = () => {
          if (this.synthesis.getVoices().length > 0) {
            resolve()
          }
        }
        
        checkVoices()
      }
    })
  }

  disableButton(message) {
    if (this.hasButtonTarget) {
      const button = this.buttonTarget
      button.disabled = true
      button.classList.add('opacity-50', 'cursor-not-allowed')
      button.title = message
    }
  }

  prepareTextForHighlighting(element, text) {
    // Remove previous highlights if any
    this.removeAllHighlights()
    
    // Find all paragraph elements that contain the text
    const paragraphs = element.querySelectorAll('p.text-gray-800')
    
    if (paragraphs.length === 0) {
      return
    }

    // Wrap each word in spans for highlighting
    // Use a global word index across all paragraphs
    let globalWordIndex = 0
    paragraphs.forEach(paragraph => {
      // Split text into words while preserving HTML structure
      const words = paragraph.textContent.split(/(\s+)/)
      let newHTML = ''
      
      words.forEach((word) => {
        if (word.trim().length > 0) {
          // Wrap word in span with global index for tracking
          newHTML += `<span class="speech-word" data-word-index="${globalWordIndex}">${this.escapeHtml(word)}</span>`
          globalWordIndex++
        } else {
          // Preserve whitespace
          newHTML += word
        }
      })
      
      paragraph.innerHTML = newHTML
    })

    // Store all word spans in order
    this.wordSpans = Array.from(element.querySelectorAll('span.speech-word'))
    this.currentWordIndex = 0
    
    console.log(`Preparato ${this.wordSpans.length} parole per evidenziazione`)
  }

  highlightWord(wordIndex) {
    // Remove previous highlights (keep last 2-3 words slightly highlighted for smooth transition)
    for (let i = 0; i < this.wordSpans.length; i++) {
      if (i < wordIndex - 2) {
        // Remove highlight from words that are too far back
        this.wordSpans[i].classList.remove('bg-yellow-300', 'text-gray-900', 'font-semibold', 'px-1', 'rounded', 'bg-yellow-200')
      } else if (i === wordIndex - 1) {
        // Keep previous word with lighter highlight
        this.wordSpans[i].classList.remove('bg-yellow-300', 'text-gray-900', 'font-semibold')
        this.wordSpans[i].classList.add('bg-yellow-200', 'px-1', 'rounded')
      }
    }

    // Add new highlight
    if (wordIndex >= 0 && wordIndex < this.wordSpans.length) {
      const wordSpan = this.wordSpans[wordIndex]
      wordSpan.classList.remove('bg-yellow-200')
      wordSpan.classList.add('bg-yellow-300', 'text-gray-900', 'font-semibold', 'px-1', 'rounded')
      
      // Scroll to word if needed (only if it's not already visible)
      const rect = wordSpan.getBoundingClientRect()
      const isVisible = rect.top >= 0 && rect.bottom <= window.innerHeight
      if (!isVisible) {
        wordSpan.scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'nearest' })
      }
      
      this.currentWordIndex = wordIndex
    }
  }

  removeAllHighlights() {
    if (this.wordSpans && this.wordSpans.length > 0) {
      this.wordSpans.forEach(span => {
        span.classList.remove('bg-yellow-300', 'text-gray-900', 'font-semibold', 'px-1', 'rounded')
      })
    }
    
    // Restore original HTML if needed
    if (this.originalText) {
      const paragraphs = this.originalText.querySelectorAll('p.text-gray-800')
      paragraphs.forEach(paragraph => {
        const spans = paragraph.querySelectorAll('span.speech-word')
        spans.forEach(span => {
          const text = span.textContent
          span.outerHTML = text
        })
      })
    }
    
    this.wordSpans = []
    this.currentWordIndex = 0
  }

  createTextMapping(originalText, textWithPauses) {
    // Create a mapping from charIndex in textWithPauses to charIndex in originalText
    // This is needed because boundary events give charIndex in textWithPauses
    this.textMapping = []
    
    let origIndex = 0
    let pauseIndex = 0
    
    while (pauseIndex < textWithPauses.length && origIndex < originalText.length) {
      // Skip pauses in textWithPauses
      if (textWithPauses[pauseIndex] === '.' && pauseIndex + 1 < textWithPauses.length && 
          textWithPauses[pauseIndex + 1] === '.' && textWithPauses[pauseIndex + 2] === '.') {
        // Skip "..." pause
        pauseIndex += 4 // "... " = 4 characters
        continue
      }
      
      // Map pauseIndex to origIndex
      this.textMapping[pauseIndex] = origIndex
      
      // If characters match, advance both
      if (textWithPauses[pauseIndex] === originalText[origIndex]) {
        origIndex++
      }
      
      pauseIndex++
    }
  }

  getWordIndexFromCharIndex(charIndexInPausedText) {
    // Convert charIndex from text with pauses to original text
    if (!this.wordSpans || this.wordSpans.length === 0) {
      return -1
    }

    // Map charIndex from paused text to original text
    let charIndex = charIndexInPausedText
    if (this.textMapping && this.textMapping[charIndexInPausedText] !== undefined) {
      charIndex = this.textMapping[charIndexInPausedText]
    }

    // Build character map from original text
    let currentCharCount = 0
    for (let i = 0; i < this.wordSpans.length; i++) {
      const span = this.wordSpans[i]
      const wordText = span.textContent.trim()
      const wordLength = wordText.length
      
      // Check if charIndex falls within this word
      if (charIndex >= currentCharCount && charIndex <= currentCharCount + wordLength) {
        return i
      }
      
      // Add word length + space
      currentCharCount += wordLength + 1 // +1 for space
    }
    
    // Fallback: if charIndex is beyond all words, return last word
    if (charIndex >= currentCharCount) {
      return this.wordSpans.length - 1
    }
    
    // Fallback: approximate based on average word length
    if (this.wordSpans.length > 0) {
      const avgWordLength = currentCharCount / this.wordSpans.length
      return Math.min(Math.floor(charIndex / avgWordLength), this.wordSpans.length - 1)
    }
    
    return -1
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  startFallbackHighlighting() {
    // Primary highlighting method based on timing
    // This is more reliable than boundary events
    if (!this.wordSpans || this.wordSpans.length === 0) {
      return
    }

    // Estimate duration: ~150 words per minute at rate 0.9
    // Each word takes approximately (60 / (150 * 0.9)) seconds = ~0.44 seconds
    const wordsPerMinute = 150 * this.rateValue
    const secondsPerWord = 60 / wordsPerMinute
    const millisecondsPerWord = secondsPerWord * 1000

    let wordIndex = 0
    
    // Calculate word durations based on actual word length
    // Longer words take more time to pronounce
    const calculateWordDuration = (word) => {
      const baseDuration = millisecondsPerWord
      const wordLength = word.length
      // Add 10ms per character for longer words
      return baseDuration + (wordLength * 10)
    }
    
    const highlightNextWord = () => {
      if (!this.isSpeaking || wordIndex >= this.wordSpans.length) {
        this.stopFallbackHighlighting()
        return
      }

      // Highlight current word
      this.highlightWord(wordIndex)
      
      // Calculate duration for next word
      const currentWord = this.wordSpans[wordIndex]?.textContent.trim() || ''
      const wordDuration = calculateWordDuration(currentWord)
      
      wordIndex++
      
      // Schedule next highlight
      setTimeout(highlightNextWord, wordDuration)
    }
    
    // Start highlighting after a short delay
    setTimeout(() => {
      if (this.isSpeaking) {
        highlightNextWord()
      }
    }, millisecondsPerWord * 0.5)
  }

  stopFallbackHighlighting() {
    if (this.highlightInterval) {
      clearInterval(this.highlightInterval)
      this.highlightInterval = null
    }
  }
}

