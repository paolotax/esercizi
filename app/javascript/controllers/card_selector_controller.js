import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="card-selector"
export default class extends Controller {
  static targets = ["card"]

  connect() {
  }

  select(event) {
    const clickedCard = event.currentTarget

    // Get the parent group
    const group = clickedCard.closest("[data-controller='card-selector']")

    if (!group) {
      console.error("Group not found")
      return
    }

    // Check if this card is already selected
    const isCurrentlySelected = clickedCard.classList.contains("bg-orange-100")

    // Deselect all cards in this group first
    const allCards = group.querySelectorAll("[data-card-selector-target='card']")
    allCards.forEach(card => {
      card.classList.remove("bg-orange-100")
      card.classList.add("bg-white")
    })

    // If it wasn't selected before, select it now
    if (!isCurrentlySelected) {
      clickedCard.classList.remove("bg-white")
      clickedCard.classList.add("bg-orange-100")
    }
  }

  // Check if a card is selected (used by exercise checker)
  isSelected(card) {
    return card.classList.contains("bg-orange-100")
  }
}
