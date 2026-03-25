# frozen_string_literal: true

class Campaign < ApplicationRecord
  STATUSES = %w[draft scheduled sending sent cancelled].freeze

  belongs_to :email_provider, optional: true
  has_many   :campaign_recipients, dependent: :destroy

  has_and_belongs_to_many :segments,
    join_table: :campaign_segments,
    foreign_key: :campaign_id

  validates :name,    presence: true
  validates :subject, presence: true
  validates :status,  inclusion: { in: STATUSES }

  scope :active,    -> { where.not(status: %w[sent cancelled]) }
  scope :sent,      -> { where(status: "sent") }
  scope :by_recent, -> { order(created_at: :desc) }

  def draft?     = status == "draft"
  def sending?   = status == "sending"
  def sent?      = status == "sent"
  def scheduled? = status == "scheduled"

  def recipient_count
    segments.joins(:contacts).where.not(contacts: { email: [nil, ""] }).select("contacts.id").distinct.count
  end

  def delivery_rate
    return 0 if total_recipients.zero?
    (delivered_count.to_f / total_recipients * 100).round(1)
  end
end
