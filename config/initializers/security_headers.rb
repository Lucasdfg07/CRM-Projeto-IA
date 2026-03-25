# frozen_string_literal: true

# =============================================================================
# Security Headers
# =============================================================================
# Headers HTTP de segurança que defendem contra ataques comuns:
# - Clickjacking (X-Frame-Options)
# - MIME sniffing (X-Content-Type-Options)
# - XSS legado (X-XSS-Protection)
# - Referrer leaking (Referrer-Policy)
# - Downgrade attacks (HSTS — só em produção com SSL)
# =============================================================================

Rails.application.config.action_dispatch.default_headers = {
  # Impede que a página seja carregada em um <iframe> em qualquer site
  "X-Frame-Options"        => "DENY",

  # Impede que o browser adivinhe o Content-Type (MIME sniffing)
  "X-Content-Type-Options" => "nosniff",

  # Ativa proteção XSS no IE/Edge legado
  "X-XSS-Protection"       => "1; mode=block",

  # Controla quais informações de origem são enviadas em requisições externas
  "Referrer-Policy"        => "strict-origin-when-cross-origin",

  # Remove header que expõe que o app usa Rails
  "X-Powered-By"           => nil,

  # HSTS: força HTTPS por 1 ano (ativado apenas se FORCE_SSL estiver true)
  # O Rails já injeta este header automaticamente quando force_ssl = true,
  # mas deixamos explícito para ambientes com proxy SSL
}.tap do |headers|
  if ENV.fetch("FORCE_SSL", "false") == "true"
    headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains; preload"
  end
end.compact
