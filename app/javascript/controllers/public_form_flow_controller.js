import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step", "progress", "progressText", "okButton", "submitButton"]

  connect() {
    this.index = 0
    this.total = this.stepTargets.length
    this.showStep(0)

    this.onKeyDown = this.onKeyDown.bind(this)
    document.addEventListener("keydown", this.onKeyDown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeyDown)
  }

  onKeyDown(event) {
    if (event.key !== "Enter") return
    if (event.shiftKey) return

    const active = this.currentStep()
    if (!active) return

    const input = active.querySelector("input, textarea, select")
    if (!input) return

    // Não intercepta Enter em textarea (Typeform normalmente permite Enter em long text com Shift+Enter)
    if (input.tagName === "TEXTAREA") return

    event.preventDefault()
    this.next()
  }

  next() {
    const active = this.currentStep()
    if (!active) return

    const input = active.querySelector("input, textarea, select")
    if (input && input.required && !this.hasValue(input)) {
      input.focus()
      input.classList.add("ring-rose-500/50", "border-rose-500/40")
      return
    }

    const nextIndex = Math.min(this.index + 1, this.total - 1)
    if (nextIndex === this.index) {
      this.submit()
      return
    }

    this.showStep(nextIndex)
  }

  prev() {
    const prevIndex = Math.max(this.index - 1, 0)
    this.showStep(prevIndex)
  }

  submit() {
    this.submitButtonTarget?.click()
  }

  showStep(idx) {
    this.index = idx
    this.stepTargets.forEach((el, i) => {
      el.classList.toggle("hidden", i !== idx)
    })

    const pct = this.total <= 0 ? 0 : Math.round(((idx) / this.total) * 100)
    if (this.hasProgressTarget) this.progressTarget.style.width = `${pct}%`
    if (this.hasProgressTextTarget) this.progressTextTarget.textContent = `${idx + 1}/${this.total}`

    const isLast = idx === this.total - 1
    if (this.hasOkButtonTarget) this.okButtonTarget.classList.toggle("hidden", isLast)
    if (this.hasSubmitButtonTarget) this.submitButtonTarget.classList.toggle("hidden", !isLast)

    const active = this.currentStep()
    const input = active?.querySelector("input, textarea, select")
    if (input) {
      setTimeout(() => input.focus(), 30)
    }
  }

  currentStep() {
    return this.stepTargets[this.index]
  }

  hasValue(input) {
    if (input.tagName === "SELECT") return input.value && input.value.trim().length > 0
    return input.value && input.value.trim().length > 0
  }
}

