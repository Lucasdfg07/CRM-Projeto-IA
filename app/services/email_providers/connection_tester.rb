# frozen_string_literal: true

module EmailProviders
  class ConnectionTester
    def initialize(provider)
      @provider = provider
    end

    def test
      settings = @provider.to_mail_settings
      smtp = Net::SMTP.new(settings[:address], settings[:port])
      smtp.enable_starttls_auto if settings[:enable_starttls_auto]
      smtp.start(
        "localhost",
        settings[:user_name],
        settings[:password],
        settings[:authentication]
      ) { |s| s.helo("localhost") }
      { success: true, message: "Conexão bem-sucedida com #{@provider.host}:#{@provider.port}" }
    rescue Net::SMTPAuthenticationError => e
      msg = "Erro de autenticação: #{e.message}"
      msg = "#{msg}\n\n#{gmail_auth_hint}" if gmail_smtp?
      { success: false, message: msg }
    rescue Errno::ECONNREFUSED => e
      { success: false, message: "Conexão recusada: #{e.message}" }
    rescue StandardError => e
      { success: false, message: "Erro: #{e.message}" }
    end

    def gmail_smtp?
      @provider.host.to_s.include?("gmail.com")
    end

    def gmail_auth_hint
      <<~HINT.strip
        Gmail não aceita a senha normal da conta no SMTP. Ative a verificação em duas etapas na conta Google e crie uma Senha de app (16 caracteres). Use essa senha aqui, com o usuário = e-mail completo (@gmail.com).
        Documentação: https://support.google.com/accounts/answer/185833
      HINT
    end
  end
end
