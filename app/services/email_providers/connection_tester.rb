# frozen_string_literal: true

module EmailProviders
  class ConnectionTester
    def initialize(provider)
      @provider = provider
    end

    def test
      settings = @provider.to_mail_settings
      auth_chain = [:plain]
      auth_chain << :login if try_login_fallback?

      last_error = nil
      auth_chain.uniq.each do |auth|
        merged = settings.merge(authentication: auth)
        begin
          connect_smtp(merged)
          ok = "Conexão bem-sucedida com #{@provider.host}:#{@provider.port}"
          ok += " (autenticação: #{auth})" if auth != :plain
          return { success: true, message: ok }
        rescue Net::SMTPAuthenticationError => e
          last_error = e
        end
      end

      { success: false, message: build_auth_failure_message(last_error) }
    rescue Errno::ECONNREFUSED => e
      { success: false, message: "Conexão recusada: #{e.message}" }
    rescue StandardError => e
      { success: false, message: "Erro: #{e.message}" }
    end

    private

    def try_login_fallback?
      !gmail_smtp? && (hostinger_smtp? || outlook_smtp?)
    end

    def connect_smtp(settings)
      smtp = Net::SMTP.new(settings[:address], settings[:port])
      if settings[:ssl]
        ctx = OpenSSL::SSL::SSLContext.new
        smtp.enable_tls(ctx)
      elsif settings[:enable_starttls_auto]
        smtp.enable_starttls_auto
      end
      smtp.start(
        "localhost",
        settings[:user_name],
        settings[:password],
        settings[:authentication]
      ) { |s| s.helo("localhost") }
    end

    def build_auth_failure_message(error)
      return "Erro de autenticação (sem detalhe)." unless error

      msg = "Erro de autenticação: #{error.message}"
      msg = "#{msg}\n\n#{gmail_auth_hint}" if gmail_smtp?
      msg = "#{msg}\n\n#{hostinger_auth_hint}" if hostinger_smtp?
      msg = "#{msg}\n\n#{outlook_auth_hint}" if outlook_smtp?
      msg = "#{msg}\n\n#{google_error_on_non_gmail_host_hint}" if google_535_on_wrong_host?(error)
      msg
    end

    def google_535_on_wrong_host?(error)
      error.message.include?("5.7.8") && !gmail_smtp?
    end

    def google_error_on_non_gmail_host_hint
      <<~HINT.strip
        A mensagem 5.7.8 costuma ser do Google. Confira se o servidor SMTP está correto (ex.: smtp.hostinger.com para e-mail Hostinger) e se o usuário é o e-mail completo da caixa. Se o domínio usa Google Workspace, as regras são as do Google (senha de app).
      HINT
    end

    def gmail_smtp?
      @provider.host.to_s.include?("gmail.com")
    end

    def hostinger_smtp?
      @provider.host.to_s.include?("hostinger")
    end

    def outlook_smtp?
      h = @provider.host.to_s.downcase
      h.include?("office365") || h.include?("outlook") || h.include?("microsoft")
    end

    def gmail_auth_hint
      <<~HINT.strip
        Gmail não aceita a senha normal da conta no SMTP. Ative a verificação em duas etapas na conta Google e crie uma Senha de app (16 caracteres). Use essa senha aqui, com o usuário = e-mail completo (@gmail.com).
        Documentação: https://support.google.com/accounts/answer/185833
      HINT
    end

    def hostinger_auth_hint
      <<~HINT.strip
        Hostinger: use o e-mail completo da caixa como usuário (ex.: contato@seudominio.com) e a senha dessa caixa criada no hPanel (E-mails). Servidor: smtp.hostinger.com, porta 587 com STARTTLS (ou 465 com SSL, conforme o painel). Se o domínio não estiver na Hostinger ou o DNS do e-mail apontar para outro provedor, use o SMTP desse provedor.
        Ajuda: https://support.hostinger.com/en/articles/1575756-how-to-get-email-account-configuration-details
      HINT
    end

    def outlook_auth_hint
      <<~HINT.strip
        Microsoft 365 / Outlook: pode ser necessária senha de app ou permissões SMTP no centro de administração. Usuário = e-mail completo.
        https://support.microsoft.com/account-billing/app-passwords
      HINT
    end
  end
end
