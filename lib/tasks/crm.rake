# frozen_string_literal: true

namespace :crm do
  desc "Resumo operacional via terminal (CLI-first AIOX)"
  task stats: :environment do
    puts({
      companies: Company.count,
      contacts: Contact.count,
      deals: Deal.count,
      activities: Activity.count,
      pipeline_open: Deal.where.not(stage: %w[won lost]).count
    }.to_json)
  end

  desc "Testar webhook N8N_WEBHOOK_URL com payload sintético"
  task :ping_n8n, [] => :environment do
    Integrations::N8nNotifier.deliver(
      action: "manual_ping",
      resource: "System",
      id: 0,
      attributes: { message: "rake crm:ping_n8n", at: Time.current.iso8601 }
    )
    puts "Ping enfileirado/enviado (verifique logs e workflow N8N)."
  end

  desc "Emitir token sugerido para CRM_API_TOKEN"
  task api_token: :environment do
    puts SecureRandom.hex(32)
  end
end
