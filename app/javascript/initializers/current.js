class Current {
  get person() {
    const currentPersonId = this.#extractContentFromMetaTag("current-person-id")
    if (currentPersonId) {
      return { id: parseInt(currentPersonId) }
    }
  }

  #extractContentFromMetaTag(name) {
    return document.head.querySelector(`meta[name="${name}"]`)?.getAttribute("content")
  }
}

window.Current = new Current()
