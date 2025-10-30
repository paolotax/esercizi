import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="slide-menu"
export default class extends Controller {
  connect() {
    console.log("Slide menu controller connected")
  }

  open(event) {
    event.preventDefault()
    const menu = document.getElementById("slide-menu")
    const overlay = document.getElementById("menu-overlay")

    if (menu && overlay) {
      menu.classList.remove("-translate-x-full")
      menu.classList.add("translate-x-0")
      overlay.classList.remove("hidden", "pointer-events-none")
      overlay.classList.add("pointer-events-auto")
      document.body.style.overflow = "hidden"
    }
  }

  close(event) {
    if (event) event.preventDefault()
    const menu = document.getElementById("slide-menu")
    const overlay = document.getElementById("menu-overlay")

    if (menu && overlay) {
      menu.classList.remove("translate-x-0")
      menu.classList.add("-translate-x-full")
      overlay.classList.add("hidden", "pointer-events-none")
      overlay.classList.remove("pointer-events-auto")
      document.body.style.overflow = ""
    }
  }
}
