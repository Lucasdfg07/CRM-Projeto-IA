import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fields", "template", "modal", "search", "paletteItem"]

  noop(event) {
    event.stopPropagation()
  }

  addField(event) {
    const type = event.currentTarget.dataset.fieldType || "text"
    const label = event.currentTarget.dataset.fieldLabel
    const placeholder = event.currentTarget.dataset.fieldPlaceholder
    const required = event.currentTarget.dataset.fieldRequired === "true"
    const options = event.currentTarget.dataset.fieldOptions
    this.insertField({ type, label, placeholder, required, options })
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

  openPalette() {
    this.modalTarget.classList.remove("hidden")
    this.modalTarget.classList.add("flex")
    this.searchTarget.value = ""
    this.filterPalette()
    setTimeout(() => this.searchTarget.focus(), 30)
  }

  closePalette() {
    this.modalTarget.classList.add("hidden")
    this.modalTarget.classList.remove("flex")
  }

  filterPalette() {
    const q = this.searchTarget.value.toLowerCase().trim()
    this.paletteItemTargets.forEach((item) => {
      const text = (item.dataset.searchText || item.textContent || "").toLowerCase()
      item.classList.toggle("hidden", q.length > 0 && !text.includes(q))
    })
  }

  addFromPalette(event) {
    const btn = event.currentTarget
    const type = btn.dataset.fieldType || "text"
    const label = btn.dataset.fieldLabel
    const placeholder = btn.dataset.fieldPlaceholder
    const required = btn.dataset.fieldRequired === "true"
    const options = btn.dataset.fieldOptions
    this.insertField({ type, label, placeholder, required, options })
    this.closePalette()
  }

  insertField({ type, label, placeholder, required, options }) {
    const html = this.templateTarget.innerHTML.replaceAll("NEW_RECORD", `${Date.now()}`)
    const wrapper = document.createElement("div")
    wrapper.innerHTML = html
    const node = wrapper.firstElementChild
    if (!node) return

    const typeSelect = node.querySelector('select[name*="[field_type]"]')
    if (typeSelect) typeSelect.value = type

    const labelInput = node.querySelector('input[name*="[label]"]')
    if (labelInput && label) labelInput.value = label

    const placeholderInput = node.querySelector('input[name*="[placeholder]"]')
    if (placeholderInput && placeholder) placeholderInput.value = placeholder

    const requiredInput = node.querySelector('input[type="checkbox"][name*="[required]"]')
    if (requiredInput) requiredInput.checked = !!required

    const optionsArea = node.querySelector('textarea[name*="[options]"]')
    if (optionsArea && options) optionsArea.value = options

    this.fieldsTarget.appendChild(node)
    node.scrollIntoView({ behavior: "smooth", block: "center" })
  }
}

