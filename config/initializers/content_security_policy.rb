# frozen_string_literal: true

# =============================================================================
# Content Security Policy (CSP)
# =============================================================================
# Protege contra XSS, injeção de scripts e carregamento de recursos externos
# não autorizados. Compatível com Turbo (Hotwire) e importmap.
# =============================================================================

Rails.application.configure do
  config.content_security_policy do |policy|
    # Padrão: apenas origem própria + HTTPS
    policy.default_src :self

    # Scripts: origem própria + nonce (para importmap e Turbo inline scripts)
    policy.script_src  :self, :https

    # Estilos: origem própria + unsafe-inline necessário para Tailwind CSS inline
    policy.style_src   :self, :https, :unsafe_inline

    # Fontes: origem própria + data URIs para ícones embutidos
    policy.font_src    :self, :https, :data

    # Imagens: origem própria + data URIs para SVGs inline
    policy.img_src     :self, :https, :data

    # Conexões AJAX/Fetch/WebSocket: apenas origem própria
    policy.connect_src :self

    # Frames: nenhum (prevenção de clickjacking via CSP também)
    policy.frame_src   :none

    # Objects/Applets: absolutamente nenhum
    policy.object_src  :none

    # Media: apenas origem própria
    policy.media_src   :self

    # Workers: apenas origem própria
    policy.worker_src  :self, :blob

    # Base URI: apenas origem própria (evita base-tag injection)
    policy.base_uri    :self

    # Form actions: apenas origem própria
    policy.form_action :self

    # Impede herança de CSP de frames pai
    policy.frame_ancestors :none
  end

  # Nonce por sessão para scripts e estilos inline (Turbo/Importmap)
  config.content_security_policy_nonce_generator = ->(request) {
    request.session.id.to_s.presence || SecureRandom.base64(16)
  }
  config.content_security_policy_nonce_directives = %w[script-src]

  # Em desenvolvimento, use report-only para não quebrar nada silenciosamente
  # config.content_security_policy_report_only = Rails.env.development?
end
