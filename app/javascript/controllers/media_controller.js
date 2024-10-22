// app/javascript/controllers/media_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["medium"]

  removeMedia(event) {
    event.preventDefault()
    const mediumId = event.params.id
    const mediumElement = document.getElementById(`medium-${mediumId}`)
    if (mediumElement) {
      mediumElement.remove()
    }
  }
}