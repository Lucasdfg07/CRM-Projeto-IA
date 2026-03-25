import { Controller } from "@hotwired/stimulus"

// Preenche automaticamente host/porta/SSL/STARTTLS com base no tipo do provedor.
// Mantém as regras "SMTP Customizado" como manual.
export default class extends Controller {
  connect() {
    this.fillDefaults()
  }

  fillDefaults() {
    const providerTypeSelect = this.element.querySelector('select[name="email_provider[provider_type]"]')
    if (!providerTypeSelect) return

    const type = providerTypeSelect.value

    const defaults = {
      gmail: { host: "smtp.gmail.com", port: "587", starttls: true, ssl: false },
      hostinger: { host: "smtp.hostinger.com", port: "587", starttls: true, ssl: false },
      outlook: { host: "smtp.office365.com", port: "587", starttls: true, ssl: false },
      smtp: null // customizado
    }

    const cfg = defaults[type]

    const hostInput = this.element.querySelector('input[name="email_provider[host]"]')
    const portInput = this.element.querySelector('input[name="email_provider[port]"]')
    const starttlsCheckbox = this.element.querySelector('input[type="checkbox"][name="email_provider[starttls]"]')
    const sslCheckbox = this.element.querySelector('input[type="checkbox"][name="email_provider[ssl]"]')

    if (!cfg) return

    // Só preenche se os campos ainda estiverem vazios (não sobrescreve configurações manuais).
    if (hostInput && !hostInput.value) hostInput.value = cfg.host
    if (portInput && !portInput.value) portInput.value = cfg.port
    if (starttlsCheckbox) starttlsCheckbox.checked = cfg.starttls
    if (sslCheckbox) sslCheckbox.checked = cfg.ssl
  }
}

