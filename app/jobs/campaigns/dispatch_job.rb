# frozen_string_literal: true

module Campaigns
  class DispatchJob < ApplicationJob
    queue_as :campaigns

    def perform(campaign_id)
      campaign = Campaign.find_by(id: campaign_id)
      return unless campaign&.sending?

      contacts = campaign.contacts_for_dispatch

      campaign.update!(total_recipients: contacts.count)

      contacts.reorder(:id).each do |contact|
        recipient = campaign.campaign_recipients.create!(
          contact_id:   contact.id,
          email:        contact.email,
          contact_name: [contact.first_name, contact.last_name].compact_blank.join(" "),
          status:       "pending"
        )
        Campaigns::SendEmailJob.perform_later(recipient.id)
      end
    end
  end
end
