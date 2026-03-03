import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["creation"]
  static classes = ["mine"]

  creationTargetConnected(element) {
    if (element.dataset.creatorId == window.Current.person?.id) {
      element.classList.add(this.mineClass)
    }
  }
}
