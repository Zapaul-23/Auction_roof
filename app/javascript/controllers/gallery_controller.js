import { Controller } from "@hotwired/stimulus"

// Product photo gallery: clicking a thumbnail shows it as the main image.
export default class extends Controller {
  static targets = [ "main", "thumb" ]

  select({ currentTarget, params: { src } }) {
    this.mainTarget.src = src
    this.thumbTargets.forEach(thumb => thumb.classList.toggle("is-active", thumb === currentTarget))
  }
}
