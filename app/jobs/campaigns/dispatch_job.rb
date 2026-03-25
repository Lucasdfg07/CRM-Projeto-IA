# frozen_string_literal: true

module Campaigns
  class DispatchJob < ApplicationJob
    queue_as :campaigns

    def perform(campaign_id)
      campaign = Campaign.find_by(id: campaign_id)
      return unless campaign&.sending?

      # Build recipient list from segments
      contacts = campaign.segments
        .joins(:contacts)
        .where.not(contacts: { email: [nil, ""] })
        .select("contacts.id, contacts.first_name, contacts.last_name, contacts.email")
        .distinct

      campaign.update!(total_recipients: contacts.count)

      contacts.each do |contact|
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
