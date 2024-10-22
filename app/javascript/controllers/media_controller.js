// app/javascript/controllers/media_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["media"]

  removeMedia(event) {
    const mediaId = event.currentTarget.dataset.id
    // Aquí puedes manejar la lógica para eliminar el medio
    console.log(`Removing media with ID: ${mediaId}`)

    // Lógica para eliminar el elemento de la vista
    const listItem = event.currentTarget.closest('li')
    listItem.remove()
  }
}
