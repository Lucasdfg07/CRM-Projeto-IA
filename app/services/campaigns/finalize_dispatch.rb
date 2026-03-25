# frozen_string_literal: true

module Campaigns
  # Marca a campanha como "sent" quando não há mais destinatários pendentes.
  # Usado após cada envio individual e ao fim do DispatchJob (ex.: zero destinatários).
  class FinalizeDispatch
    def self.call(campaign_id)
      new(campaign_id).call
    end

    def initialize(campaign_id)
      @campaign_id = campaign_id
    end

    def call
      campaign = Campaign.find_by(id: @campaign_id)
      return unless campaign&.sending?
      return if campaign.campaign_recipients.pending.exists?

      campaign.update!(status: "sent")
    rescue StandardError
      nil
    end
  end
end
