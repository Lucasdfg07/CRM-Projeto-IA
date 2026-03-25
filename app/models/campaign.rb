# frozen_string_literal: true

class Campaign < ApplicationRecord
  STATUSES = %w[draft scheduled sending sent cancelled].freeze
  # email: só quem tem e-mail | phone: só quem tem telefone | both: e-mail e telefone
  RECIPIENT_FILTERS = %w[email phone both].freeze

  belongs_to :email_provider, optional: true
  has_many   :campaign_recipients, dependent: :destroy

  has_and_belongs_to_many :segments,
    join_table: :campaign_segments,
    foreign_key: :campaign_id

  validates :name,    presence: true
  validates :subject, presence: true
  validates :status,  inclusion: { in: STATUSES }
  validates :recipient_filter, inclusion: { in: RECIPIENT_FILTERS }

  scope :active,    -> { where.not(status: %w[sent cancelled]) }
  scope :sent,      -> { where(status: "sent") }
  scope :by_recent, -> { order(created_at: :desc) }

  def draft?     = status == "draft"
  def sending?   = status == "sending"
  def sent?      = status == "sent"
  def scheduled? = status == "scheduled"

  def recipient_count
    contacts_for_dispatch.count
  end

  # Contatos dos segmentos alvo, após filtro de e-mail/telefone (envio exige e-mail).
  def contacts_for_dispatch
    return Contact.none if segment_ids.blank?

    rel = Contact.joins(:segments).where(segments: { id: segment_ids })
    rel = apply_recipient_filter(rel)
    rel.where.not(email: [nil, ""]).distinct
  end

  def apply_recipient_filter(scope)
    case recipient_filter
    when "phone"
      scope.merge(Contact.with_phone)
    when "both"
      scope.merge(Contact.with_email_and_phone)
    else
      scope.merge(Contact.with_email)
    end
  end

  def delivery_rate
    return 0 if total_recipients.zero?
    (delivered_count.to_f / total_recipients * 100).round(1)
  end
end
