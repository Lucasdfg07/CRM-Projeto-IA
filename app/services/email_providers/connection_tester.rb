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
      { success: false, message: "Erro de autenticação: #{e.message}" }
    rescue Errno::ECONNREFUSED => e
      { success: false, message: "Conexão recusada: #{e.message}" }
    rescue StandardError => e
      { success: false, message: "Erro: #{e.message}" }
    end
  end
end
