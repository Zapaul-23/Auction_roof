import { Controller } from "@hotwired/stimulus"

// Shows thumbnails of the files picked in a file input before they are uploaded.
export default class extends Controller {
  static targets = [ "input", "preview" ]

  disconnect() {
    this.#revoke()
  }

  show() {
    this.#revoke()
    this.previewTarget.replaceChildren(...Array.from(this.inputTarget.files).map(file => this.#tile(file)))
  }

  #tile(file) {
    const item = document.createElement("li")
    item.className = "image-tile"

    if (file.type.startsWith("image/")) {
      const img = document.createElement("img")
      img.src = URL.createObjectURL(file)
      img.alt = file.name
      item.append(img)
    }

    const caption = document.createElement("span")
    caption.className = "image-caption"
    caption.textContent = `${file.name} (${(file.size / 1024 / 1024).toFixed(1)} MB)`
    item.append(caption)
    return item
  }

  #revoke() {
    this.previewTarget.querySelectorAll("img").forEach(img => URL.revokeObjectURL(img.src))
  }
}
