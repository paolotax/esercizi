import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="word-classifier"
export default class extends Controller {
  connect() {
    console.log("Word classifier controller connected")
  }
}
