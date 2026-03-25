# frozen_string_literal: true

# =============================================================================
# Rack::Attack — Proteção contra Brute Force, Rate Limiting e DoS
# =============================================================================
# Documentação: https://github.com/rack/rack-attack
# =============================================================================

class Rack::Attack
  # ---------------------------------------------------------------------------
  # Cache store (usa Rails.cache — memory_store em dev, configure Redis em prod)
  # ---------------------------------------------------------------------------
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # ---------------------------------------------------------------------------
  # SAFELIST — IPs internos nunca são bloqueados
  # ---------------------------------------------------------------------------
  safelist("allow-localhost") do |req|
    req.ip == "127.0.0.1" || req.ip == "::1"
  end

  # ---------------------------------------------------------------------------
  # THROTTLE 1 — Login: máximo 5 tentativas por minuto por IP
  # Protege contra brute force de senhas
  # ---------------------------------------------------------------------------
  throttle("login/ip", limit: 5, period: 1.minute) do |req|
    req.ip if req.path == "/session" && req.post?
  end

  # ---------------------------------------------------------------------------
  # THROTTLE 2 — Login: máximo 10 tentativas por hora por e-mail
  # Protege contra ataques distribuídos ao mesmo usuário
  # ---------------------------------------------------------------------------
  throttle("login/email", limit: 10, period: 1.hour) do |req|
    if req.path == "/session" && req.post?
      req.params["email"].to_s.downcase.strip.presence
    end
  end

  # ---------------------------------------------------------------------------
  # THROTTLE 3 — API: máximo 100 requisições por minuto por token
  # ---------------------------------------------------------------------------
  throttle("api/token", limit: 100, period: 1.minute) do |req|
    if req.path.start_with?("/api/")
      req.get_header("HTTP_AUTHORIZATION").to_s.split(" ").last.presence
    end
  end

  # ---------------------------------------------------------------------------
  # THROTTLE 4 — API: máximo 300 requisições por 5 minutos por IP (fallback)
  # ---------------------------------------------------------------------------
  throttle("api/ip", limit: 300, period: 5.minutes) do |req|
    req.ip if req.path.start_with?("/api/")
  end

  # ---------------------------------------------------------------------------
  # THROTTLE 5 — Geral: máximo 500 requisições por 5 minutos por IP
  # ---------------------------------------------------------------------------
  throttle("req/ip", limit: 500, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets/")
  end

  # ---------------------------------------------------------------------------
  # BLOCKLIST — Bloquear headers suspeitos de scanners automáticos
  # ---------------------------------------------------------------------------
  blocklist("block-bad-user-agents") do |req|
    bad_agents = /sqlmap|nikto|nmap|masscan|zgrab|dirbuster|gobuster|wfuzz|nuclei/i
    req.user_agent.to_s.match?(bad_agents)
  end

  # ---------------------------------------------------------------------------
  # RESPOSTA PERSONALIZADA para requisições bloqueadas
  # ---------------------------------------------------------------------------
  self.throttled_responder = lambda do |req|
    is_api = req.path.start_with?("/api/")
    retry_after = (req.env["rack.attack.match_data"] || {})[:period]

    if is_api
      [
        429,
        {
          "Content-Type"  => "application/json",
          "Retry-After"   => retry_after.to_s
        },
        [{ error: "Muitas requisições. Tente novamente em breve.", retry_after: retry_after }.to_json]
      ]
    else
      [
        429,
        {
          "Content-Type" => "text/html; charset=utf-8",
          "Retry-After"  => retry_after.to_s
        },
        ["<h1>Muitas tentativas</h1><p>Aguarde antes de tentar novamente.</p>"]
      ]
    end
  end

  self.blocklisted_responder = lambda do |_req|
    [
      403,
      { "Content-Type" => "application/json" },
      [{ error: "Acesso negado." }.to_json]
    ]
  end
end
