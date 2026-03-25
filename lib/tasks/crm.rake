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

  namespace :email_marketing do
    desc "Enfileira disparo de campanhas agendadas (scheduled_at <= agora)"
    task dispatch_scheduled: :environment do
      due = Campaign.where(status: "scheduled")
        .where("scheduled_at IS NOT NULL AND scheduled_at <= ?", Time.current)

      total = due.count
      due.find_each do |campaign|
        next unless campaign.email_provider.present? && campaign.segments.exists?

        campaign.update!(status: "sending", sent_at: Time.current)
        Campaigns::DispatchJob.perform_later(campaign.id)
      end

      puts "Campanhas enfileiradas: #{total}"
    end

    desc "Enfileira disparo imediato de uma campanha (draft/scheduled)"
    task :send_now, [:campaign_id] => :environment do |_t, args|
      campaign_id = args[:campaign_id].to_i
      if campaign_id.zero?
        puts "Uso: bin/rails crm:email_marketing:send_now[campaign_id]"
        exit 1
      end

      campaign = Campaign.find_by(id: campaign_id)
      unless campaign
        puts "Campanha não encontrada: #{campaign_id}"
        exit 1
      end

      unless campaign.draft? || campaign.scheduled?
        puts "Campanha não está em draft/scheduled: status=#{campaign.status}"
        exit 1
      end

      if campaign.email_provider.nil?
        puts "Selecione um provedor de email antes de enviar."
        exit 1
      end

      if campaign.segments.empty?
        puts "Adicione pelo menos um segmento antes de enviar."
        exit 1
      end

      campaign.update!(status: "sending", sent_at: Time.current)
      Campaigns::DispatchJob.perform_later(campaign.id)
      puts "Campanha enfileirada: #{campaign.id} (#{campaign.name})"
    end
  end
end
