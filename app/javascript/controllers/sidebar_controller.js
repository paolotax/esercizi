import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar"
export default class extends Controller {
  static targets = ["sidebar"]

  connect() {
    console.log("Sidebar controller connected")
    console.log("Sidebar target:", this.hasSidebarTarget)
  }

  toggle(event) {
    if (event) event.preventDefault()
    console.log("Toggling sidebar...")

    if (this.hasSidebarTarget) {
      this.sidebarTarget.classList.toggle("hidden")
      console.log("Sidebar toggled")
    } else {
      console.error("Sidebar target not found")
    }
  }

  close(event) {
    if (event) event.preventDefault()
    console.log("Closing sidebar...")

    if (this.hasSidebarTarget) {
      this.sidebarTarget.classList.add("hidden")
      console.log("Sidebar closed")
    } else {
      console.error("Sidebar target not found")
    }
  }
}
