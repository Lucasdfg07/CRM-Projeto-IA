# frozen_string_literal: true

class CampaignRecipient < ApplicationRecord
  STATUSES = %w[pending delivered failed].freeze

  belongs_to :campaign
  belongs_to :contact, optional: true

  validates :email,  presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :delivered, -> { where(status: "delivered") }
  scope :failed,    -> { where(status: "failed") }
  scope :pending,   -> { where(status: "pending") }
end
