import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["colorBox", "rhymeWord"]
  static values = {
    selectedColor: { type: String, default: "" }
  }

  connect() {
    this.selectedColorValue = ""
  }

  // Get color from element's classes
  getColorFromElement(element) {
    if (element.classList.contains('bg-yellow-300')) return 'yellow'
    if (element.classList.contains('bg-pink-300')) return 'pink'
    if (element.classList.contains('bg-blue-300')) return 'blue'
    if (element.classList.contains('bg-green-300')) return 'green'
    if (element.classList.contains('bg-orange-300')) return 'orange'
    if (element.classList.contains('bg-purple-300')) return 'purple'
    if (element.classList.contains('bg-cyan-300')) return 'cyan'
    if (element.classList.contains('bg-teal-300')) return 'teal'
    if (element.classList.contains('bg-indigo-300')) return 'indigo'
    if (element.classList.contains('bg-red-300')) return 'red'
    return null
  }

  selectColor(event) {
    const colorBox = event.currentTarget
    const color = colorBox.dataset.color
    
    // Remove selection from all color boxes
    this.colorBoxTargets.forEach(box => {
      box.classList.remove('ring-4', 'ring-offset-2', 'ring-gray-800', 'scale-110', 'shadow-lg')
      box.classList.add('ring-2', 'ring-gray-300')
    })
    
    // Add selection to clicked box
    colorBox.classList.add('ring-4', 'ring-offset-2', 'ring-gray-800', 'scale-110', 'shadow-lg')
    colorBox.classList.remove('ring-2', 'ring-gray-300')
    
    this.selectedColorValue = color
    
  }

  highlightRhyme(event) {
    if (!this.selectedColorValue) {
      // No color selected, show hint
      alert("Prima seleziona un colore!")
      return
    }

    const wordElement = event.currentTarget
    const rhymeGroup = wordElement.dataset.rhymeGroup
    
    if (!rhymeGroup) {
      return
    }

    // Remove all previous color classes from this word
    wordElement.classList.remove(
      'bg-yellow-200', 'bg-pink-200', 'bg-blue-200', 'bg-green-200',
      'bg-yellow-300', 'bg-pink-300', 'bg-blue-300', 'bg-green-300',
      'bg-orange-300', 'bg-purple-300', 'bg-cyan-300', 'bg-teal-300',
      'bg-indigo-300', 'bg-red-300',
      'text-yellow-900', 'text-pink-900', 'text-blue-900', 'text-green-900',
      'text-orange-900', 'text-purple-900', 'text-cyan-900', 'text-teal-900',
      'text-indigo-900', 'text-red-900',
      'font-bold', 'px-1', 'rounded', 'underline', 'animate-pulse'
    )
    
    // Add new color based on selection
    const colorClasses = this.getColorClasses(this.selectedColorValue)
    wordElement.classList.add(...colorClasses)
    
    // Visual feedback
    wordElement.classList.add('animate-pulse')
    setTimeout(() => {
      wordElement.classList.remove('animate-pulse')
    }, 300)
    
  }

  getColorClasses(color) {
    const colorMap = {
      'yellow': ['bg-yellow-300', 'text-yellow-900', 'font-bold', 'px-1', 'rounded'],
      'pink': ['bg-pink-300', 'text-pink-900', 'font-bold', 'px-1', 'rounded'],
      'blue': ['bg-blue-300', 'text-blue-900', 'font-bold', 'px-1', 'rounded'],
      'green': ['bg-green-300', 'text-green-900', 'font-bold', 'px-1', 'rounded'],
      'orange': ['bg-orange-300', 'text-orange-900', 'font-bold', 'px-1', 'rounded'],
      'purple': ['bg-purple-300', 'text-purple-900', 'font-bold', 'px-1', 'rounded'],
      'cyan': ['bg-cyan-300', 'text-cyan-900', 'font-bold', 'px-1', 'rounded'],
      'teal': ['bg-teal-300', 'text-teal-900', 'font-bold', 'px-1', 'rounded'],
      'indigo': ['bg-indigo-300', 'text-indigo-900', 'font-bold', 'px-1', 'rounded'],
      'red': ['bg-red-300', 'text-red-900', 'font-bold', 'px-1', 'rounded']
    }
    
    return colorMap[color] || []
  }

  clearHighlights() {
    // Find all rhyme words in the document
    const allRhymeWords = this.element.querySelectorAll('[data-rhyme-group]')
    allRhymeWords.forEach(word => {
      word.classList.remove(
        'bg-yellow-200', 'bg-pink-200', 'bg-blue-200', 'bg-green-200',
        'bg-yellow-300', 'bg-pink-300', 'bg-blue-300', 'bg-green-300',
        'bg-orange-300', 'bg-purple-300', 'bg-cyan-300', 'bg-teal-300',
        'bg-indigo-300', 'bg-red-300',
        'text-yellow-900', 'text-pink-900', 'text-blue-900', 'text-green-900',
        'text-orange-900', 'text-purple-900', 'text-cyan-900', 'text-teal-900',
        'text-indigo-900', 'text-red-900',
        'font-bold', 'px-1', 'rounded', 'underline', 'animate-pulse'
      )
    })
    
    // Also clear color selection
    this.colorBoxTargets.forEach(box => {
      box.classList.remove('ring-4', 'ring-offset-2', 'ring-gray-800', 'scale-110', 'shadow-lg')
      box.classList.add('ring-2', 'ring-gray-300')
    })
    this.selectedColorValue = ""
  }

  checkAnswers(event) {
    if (event) {
      event.preventDefault()
    }

    // Remove previous check marks
    const allRhymeWords = this.element.querySelectorAll('[data-rhyme-group]')
    allRhymeWords.forEach(word => {
      word.classList.remove('ring-2', 'ring-green-500', 'ring-red-500')
    })

    // Get all rhyme groups
    const groups = {}
    
    // Group words by rhyme group
    allRhymeWords.forEach(word => {
      const group = word.dataset.rhymeGroup
      if (!groups[group]) {
        groups[group] = []
      }
      groups[group].push(word)
    })

    let allCorrect = true
    let correctGroups = 0
    let incorrectGroups = 0
    let uncoloredGroups = 0

    // Track which color is used by which group
    const groupColors = {} // { groupId: color }
    const groupStatus = {} // { groupId: 'valid' | 'invalid' | 'uncolored' }

    // First pass: Check if each group has all words with the same color
    Object.keys(groups).forEach(groupId => {
      const words = groups[groupId]
      const colors = words.map(word => this.getColorFromElement(word)).filter(c => c !== null) // Get colors, filter null
      
      
      if (colors.length === 0) {
        // No words colored in this group
        uncoloredGroups++
        groupStatus[groupId] = 'uncolored'
        return
      }

      // Check if all words in group have the same color
      const uniqueColors = new Set(colors)
      if (colors.length === words.length && uniqueColors.size === 1) {
        // All words have the same color - store the color for this group
        groupColors[groupId] = colors[0]
        groupStatus[groupId] = 'valid'
      } else {
        // Words have different colors or not all colored - invalid
        incorrectGroups++
        allCorrect = false
        groupStatus[groupId] = 'invalid'
        words.forEach(word => {
          if (this.getColorFromElement(word)) {
            word.classList.add('ring-2', 'ring-red-500', 'ring-offset-1')
          }
        })
      }
    })

    // Second pass: Check if different groups use the same color (which is incorrect)
    const processedGroups = new Set() // Track groups already processed for conflicts
    
    Object.keys(groupColors).forEach(groupId => {
      if (processedGroups.has(groupId)) {
        return // Already processed
      }
      
      const groupColor = groupColors[groupId]
      
      // Check if any other group uses the same color
      const conflictingGroups = Object.keys(groupColors).filter(gId => 
        gId !== groupId && groupColors[gId] === groupColor
      )
      
      if (conflictingGroups.length > 0) {
        // This group conflicts with another group - mark all conflicting groups as incorrect
        const allConflictingGroups = [groupId, ...conflictingGroups]
        allConflictingGroups.forEach(conflictGroupId => {
          processedGroups.add(conflictGroupId)
          
          if (groupStatus[conflictGroupId] === 'valid') {
            // This group was valid, now it's invalid due to conflict
            incorrectGroups++
            groupStatus[conflictGroupId] = 'invalid'
          }
          
          const words = groups[conflictGroupId]
          words.forEach(word => {
            word.classList.remove('ring-2', 'ring-green-500', 'ring-offset-1')
            word.classList.add('ring-2', 'ring-red-500', 'ring-offset-1')
          })
        })
        
        allCorrect = false
      } else if (groupStatus[groupId] === 'valid') {
        // This group is valid and has no conflicts - mark as correct
        processedGroups.add(groupId)
        correctGroups++
        const words = groups[groupId]
        words.forEach(word => {
          word.classList.add('ring-2', 'ring-green-500', 'ring-offset-1')
        })
      }
    })
    

    // Show feedback
    let message = ""
    if (uncoloredGroups === Object.keys(groups).length) {
      message = "⚠️ Devi colorare le parole prima di controllare!"
    } else if (allCorrect && correctGroups > 0) {
      message = `✅ Ottimo! Tutte le rime sono abbinate correttamente! (${correctGroups} gruppi corretti)`
    } else {
      message = `⚠️ Alcune rime non sono abbinate correttamente.\n\nCorrette: ${correctGroups}\nErrate: ${incorrectGroups}`
      if (uncoloredGroups > 0) {
        message += `\nNon colorate: ${uncoloredGroups}`
      }
    }

    alert(message)
    
    return { allCorrect, correctGroups, incorrectGroups, uncoloredGroups }
  }
}

