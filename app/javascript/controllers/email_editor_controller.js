import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas", "blocks", "output", "placeholder"]

  connect() {
    this.blocks = []
    this.selectedIndex = null

    // Load existing content if editing
    const existing = this.outputTarget.value
    if (existing && existing.trim()) {
      this.blocksTarget.innerHTML = existing
      this.placeholderTarget.style.display = "none"
      this.syncOutput()
    }

    // Re-attach controls to existing blocks
    this.attachBlockControls()
  }

  addBlock(event) {
    const type = event.currentTarget.dataset.blockType
    const block = this.createBlock(type)
    this.placeholderTarget.style.display = "none"
    this.blocksTarget.appendChild(block)
    this.syncOutput()
    block.scrollIntoView({ behavior: "smooth", block: "center" })
  }

  createBlock(type) {
    const wrapper = document.createElement("div")
    wrapper.className = "email-block relative group"
    wrapper.dataset.blockType = type
    wrapper.innerHTML = this.blockControls() + this.blockHTML(type)

    // Make editable areas contenteditable
    wrapper.querySelectorAll("[data-editable]").forEach(el => {
      el.contentEditable = "true"
      el.addEventListener("input", () => this.syncOutput())
      el.addEventListener("blur", () => this.syncOutput())
    })

    // Color pickers
    wrapper.querySelectorAll("[data-color-target]").forEach(picker => {
      picker.addEventListener("input", (e) => {
        const target = wrapper.querySelector(picker.dataset.colorTarget)
        if (target) target.style.backgroundColor = e.target.value
        this.syncOutput()
      })
    })

    // Link inputs
    wrapper.querySelectorAll("[data-link-target]").forEach(input => {
      input.addEventListener("input", (e) => {
        const target = wrapper.querySelector(input.dataset.linkTarget)
        if (target) target.href = e.target.value
        this.syncOutput()
      })
    })

    // Control buttons
    wrapper.querySelector("[data-action-up]")?.addEventListener("click", () => this.moveBlock(wrapper, -1))
    wrapper.querySelector("[data-action-down]")?.addEventListener("click", () => this.moveBlock(wrapper, 1))
    wrapper.querySelector("[data-action-remove]")?.addEventListener("click", () => {
      wrapper.remove()
      this.syncOutput()
      if (!this.blocksTarget.querySelector(".email-block")) {
        this.placeholderTarget.style.display = "flex"
      }
    })

    return wrapper
  }

  blockControls() {
    return `
      <div class="absolute top-0 right-0 z-10 hidden group-hover:flex gap-1 bg-slate-800 rounded-bl-lg px-2 py-1 shadow-lg">
        <button type="button" data-action-up class="text-slate-400 hover:text-white text-xs px-1" title="Mover para cima">↑</button>
        <button type="button" data-action-down class="text-slate-400 hover:text-white text-xs px-1" title="Mover para baixo">↓</button>
        <button type="button" data-action-remove class="text-red-400 hover:text-red-300 text-xs px-1" title="Remover">✕</button>
      </div>
      <div class="absolute inset-0 hidden group-hover:block pointer-events-none ring-2 ring-indigo-500 ring-inset rounded-sm z-0"></div>
    `
  }

  blockHTML(type) {
    const blocks = {
      header: `
        <div style="background-color:#1e1b4b;padding:32px 40px;text-align:center;" data-block-content>
          <div style="margin-bottom:8px;">
            <label style="font-size:10px;color:#a5b4fc;display:block;margin-bottom:4px;">Cor de fundo:</label>
            <input type="color" value="#1e1b4b" data-color-target="[data-block-content]" style="width:32px;height:24px;border:none;cursor:pointer;background:none;">
          </div>
          <h1 data-editable style="color:#ffffff;font-size:28px;font-weight:700;margin:0;font-family:Arial,sans-serif;outline:none;min-width:20px;">
            Sua Empresa
          </h1>
          <p data-editable style="color:#a5b4fc;font-size:14px;margin:8px 0 0;font-family:Arial,sans-serif;outline:none;min-width:20px;">
            Slogan ou descrição
          </p>
        </div>`,

      text: `
        <div style="padding:32px 40px;background:#ffffff;" data-block-content>
          <div style="margin-bottom:8px;">
            <label style="font-size:10px;color:#6b7280;display:block;margin-bottom:4px;">Cor de fundo:</label>
            <input type="color" value="#ffffff" data-color-target="[data-block-content]" style="width:32px;height:24px;border:none;cursor:pointer;background:none;">
          </div>
          <div data-editable style="font-family:Arial,sans-serif;font-size:16px;line-height:1.6;color:#374151;outline:none;min-height:60px;">
            <p style="margin:0 0 12px;">Olá {{nome}},</p>
            <p style="margin:0;">Escreva o conteúdo do seu email aqui. Você pode editar este texto clicando nele.</p>
          </div>
        </div>`,

      button: `
        <div style="padding:24px 40px;background:#ffffff;text-align:center;" data-block-content>
          <div style="margin-bottom:8px;">
            <label style="font-size:10px;color:#6b7280;display:block;margin-bottom:4px;">Cor do botão:</label>
            <input type="color" value="#4f46e5" data-color-target="a[data-btn]" style="width:32px;height:24px;border:none;cursor:pointer;background:none;">
          </div>
          <a data-btn href="https://example.com" data-link-target="a[data-btn]" style="display:inline-block;background-color:#4f46e5;color:#ffffff;font-family:Arial,sans-serif;font-size:16px;font-weight:700;padding:14px 36px;border-radius:8px;text-decoration:none;">
            <span data-editable style="outline:none;">Clique aqui</span>
          </a>
          <div style="margin-top:8px;">
            <label style="font-size:10px;color:#6b7280;">Link:</label>
            <input type="text" placeholder="https://" data-link-target="a[data-btn]" value="https://example.com" style="width:200px;font-size:11px;padding:3px 6px;border:1px solid #e5e7eb;border-radius:4px;margin-left:4px;">
          </div>
        </div>`,

      image: `
        <div style="padding:24px 40px;background:#ffffff;text-align:center;" data-block-content>
          <div style="background:#f3f4f6;border:2px dashed #d1d5db;border-radius:8px;padding:32px;color:#9ca3af;font-family:Arial,sans-serif;">
            <svg style="width:48px;height:48px;margin:0 auto 8px;display:block;color:#d1d5db;" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
            <p data-editable style="margin:0;font-size:14px;outline:none;">Substitua por uma URL de imagem</p>
            <input type="text" placeholder="https://exemplo.com/imagem.jpg" data-link-target="img[data-img]" style="width:80%;margin-top:8px;font-size:11px;padding:4px 8px;border:1px solid #e5e7eb;border-radius:4px;">
            <img data-img src="" alt="" style="display:none;max-width:100%;height:auto;border-radius:4px;" onerror="this.style.display='none'">
          </div>
        </div>`,

      divider: `
        <div style="padding:16px 40px;background:#ffffff;" data-block-content>
          <div style="margin-bottom:6px;">
            <label style="font-size:10px;color:#6b7280;">Cor:</label>
            <input type="color" value="#e5e7eb" data-color-target="hr[data-hr]" style="width:28px;height:20px;border:none;cursor:pointer;background:none;margin-left:4px;">
          </div>
          <hr data-hr style="border:none;border-top:2px solid #e5e7eb;margin:0;">
        </div>`,

      footer: `
        <div style="background:#f9fafb;padding:24px 40px;text-align:center;" data-block-content>
          <div style="margin-bottom:8px;">
            <label style="font-size:10px;color:#6b7280;display:block;margin-bottom:4px;">Cor de fundo:</label>
            <input type="color" value="#f9fafb" data-color-target="[data-block-content]" style="width:32px;height:24px;border:none;cursor:pointer;background:none;">
          </div>
          <div data-editable style="font-family:Arial,sans-serif;font-size:13px;color:#6b7280;outline:none;">
            <p style="margin:0 0 6px;">© 2026 Sua Empresa · Todos os direitos reservados</p>
            <p style="margin:0;font-size:12px;">Para cancelar o recebimento, <a href="#" style="color:#4f46e5;">clique aqui</a>.</p>
          </div>
        </div>`
    }
    return blocks[type] || blocks.text
  }

  moveBlock(block, direction) {
    const parent = block.parentNode
    const blocks = Array.from(parent.children).filter(el => el.classList.contains("email-block"))
    const idx = blocks.indexOf(block)
    const target = blocks[idx + direction]
    if (!target) return
    if (direction === -1) {
      parent.insertBefore(block, target)
    } else {
      parent.insertBefore(target, block)
    }
    this.syncOutput()
  }

  syncOutput() {
    // Clone blocks, strip editor controls, keep only email HTML
    const clone = this.blocksTarget.cloneNode(true)
    clone.querySelectorAll("[data-action-up],[data-action-down],[data-action-remove]").forEach(el => el.closest(".absolute")?.remove())
    clone.querySelectorAll("[data-action-up],[data-action-down],[data-action-remove]").forEach(el => el.remove())
    clone.querySelectorAll("[contenteditable]").forEach(el => el.removeAttribute("contenteditable"))
    clone.querySelectorAll(".group-hover\\:flex, .group-hover\\:block").forEach(el => el.remove())
    clone.querySelectorAll("input[type=color], input[type=text][data-link-target]").forEach(el => el.remove())
    clone.querySelectorAll("label").forEach(el => {
      // Only remove UI labels (ones without for attribute that are inside editor controls)
      if (!el.htmlFor) el.remove()
    })
    clone.querySelectorAll(".email-block").forEach(b => {
      b.classList.remove("email-block", "relative", "group")
    })

    // Build full email HTML
    const html = this.wrapEmail(clone.innerHTML)
    this.outputTarget.value = html
  }

  wrapEmail(innerHtml) {
    return `<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title>Email</title>
</head>
<body style="margin:0;padding:0;background-color:#f4f4f5;font-family:Arial,Helvetica,sans-serif;">
<table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color:#f4f4f5;">
<tr><td align="center" style="padding:20px 0;">
<table role="presentation" width="600" cellspacing="0" cellpadding="0" style="max-width:600px;width:100%;background:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">
<tr><td>${innerHtml}</td></tr>
</table>
</td></tr>
</table>
</body>
</html>`
  }

  preview() {
    this.syncOutput()
    const html = this.outputTarget.value
    const win = window.open("", "_blank")
    win.document.write(html)
    win.document.close()
  }

  clearAll() {
    if (!confirm("Limpar todo o conteúdo do email?")) return
    this.blocksTarget.innerHTML = ""
    this.blocksTarget.appendChild(this.createPlaceholderDiv())
    this.placeholderTarget.style.display = "flex"
    this.outputTarget.value = ""
  }

  createPlaceholderDiv() {
    const div = document.createElement("div")
    div.setAttribute("data-email-editor-target", "placeholder")
    div.className = "flex items-center justify-center h-64 text-slate-400 text-sm p-8 text-center"
    div.innerHTML = `<div>
      <svg class="w-10 h-10 mx-auto mb-3 text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>
      <p>Clique em um bloco acima para começar a montar seu email</p>
    </div>`
    return div
  }

  attachBlockControls() {
    this.blocksTarget.querySelectorAll(".email-block").forEach(block => {
      block.querySelector("[data-action-up]")?.addEventListener("click", () => this.moveBlock(block, -1))
      block.querySelector("[data-action-down]")?.addEventListener("click", () => this.moveBlock(block, 1))
      block.querySelector("[data-action-remove]")?.addEventListener("click", () => {
        block.remove()
        this.syncOutput()
      })
    })
  }
}
