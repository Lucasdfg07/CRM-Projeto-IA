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
    rescue StandardError => e
      recipient&.update!(status: "failed", error_message: e.message.truncate(500))
      recipient&.campaign&.increment!(:failed_count)
    end
  end
end
