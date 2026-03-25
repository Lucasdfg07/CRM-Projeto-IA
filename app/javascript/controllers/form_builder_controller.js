import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fields", "template"]

  addField(event) {
    const type = event.currentTarget.dataset.fieldType || "text"
    const html = this.templateTarget.innerHTML.replaceAll("NEW_RECORD", `${Date.now()}`)
    const wrapper = document.createElement("div")
    wrapper.innerHTML = html
    const node = wrapper.firstElementChild
    if (!node) return

    // define o tipo escolhido imediatamente
    const select = node.querySelector('select[name*="[field_type]"]')
    if (select) select.value = type

    this.fieldsTarget.appendChild(node)
  }

  removeField(event) {
    const fieldCard = event.currentTarget.closest("div.bg-slate-900")
    if (!fieldCard) return

    // Se já persistido, marca _destroy=1. Senão, remove do DOM.
    const destroyInput = fieldCard.querySelector('input[name*="[_destroy]"]')
    const idInput = fieldCard.querySelector('input[name*="[id]"]')

    if (idInput && destroyInput) {
      destroyInput.value = "1"
      fieldCard.style.display = "none"
    } else {
      fieldCard.remove()
    }
  }
}

