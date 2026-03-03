import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="nav"
export default class extends Controller {
  click(event) {
    const summary = event.target.closest("summary")
    if (summary) {
      // Accordion: close all other open submenus when one is opened
      const opened = summary.closest("details")
      this.element.querySelectorAll("details[open]").forEach(d => {
        if (d !== opened) d.removeAttribute("open")
      })
      return
    }

    // Close submenu after a link inside it is clicked
    if (event.target.closest("a")) {
      event.target.closest("details")?.removeAttribute("open")
    }
  }
}
