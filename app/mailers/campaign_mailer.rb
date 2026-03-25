# frozen_string_literal: true

class CampaignMailer < ApplicationMailer
  def campaign_email(campaign_recipient)
    @recipient = campaign_recipient
    @campaign  = campaign_recipient.campaign
    @html_body = personalize(@campaign.html_body, campaign_recipient)

    provider = @campaign.email_provider
    if provider
      mail(
        to:           campaign_recipient.email,
        subject:      @campaign.subject,
        from:         "#{@campaign.from_name.presence || provider.from_name} <#{@campaign.from_email.presence || provider.from_email}>",
        reply_to:     @campaign.reply_to.presence,
        delivery_method_options: provider.to_mail_settings
      )
    else
      mail(to: campaign_recipient.email, subject: @campaign.subject)
    end
  end

  private

  def personalize(html, recipient)
    return html.to_s unless html.present?
    html
      .gsub("{{nome}}", recipient.contact_name.to_s.split.first || "")
      .gsub("{{nome_completo}}", recipient.contact_name.to_s)
      .gsub("{{email}}", recipient.email.to_s)
  end
end
