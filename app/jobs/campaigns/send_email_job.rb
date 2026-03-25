# frozen_string_literal: true

module Campaigns
  class SendEmailJob < ApplicationJob
    queue_as :campaigns

    def perform(recipient_id)
      recipient = CampaignRecipient.find_by(id: recipient_id)
      return unless recipient&.pending?

      CampaignMailer.campaign_email(recipient).deliver_now

      recipient.update!(status: "delivered", sent_at: Time.current)
      recipient.campaign.increment!(:delivered_count)
      finalize_campaign_if_complete(recipient.campaign.id)
    rescue StandardError => e
      campaign = recipient&.campaign
      recipient&.update!(status: "failed", error_message: e.message.truncate(500))
      recipient&.campaign&.increment!(:failed_count)
      finalize_campaign_if_complete(campaign&.id) if campaign&.id
    end

    private

    def finalize_campaign_if_complete(campaign_id)
      return if campaign_id.blank?

      campaign = Campaign.find_by(id: campaign_id)
      return unless campaign
      return unless campaign.sending?

      # Quando não houver mais destinatários pendentes, marcamos a campanha como concluída.
      # Entregas/erros já ficam refletidos em delivered_count/failed_count.
      return if campaign.campaign_recipients.pending.exists?

      campaign.update!(status: "sent")
    rescue StandardError
      # Evita que uma falha na finalização quebre o envio individual.
      nil
    end
  end
end
