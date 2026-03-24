# frozen_string_literal: true

class Activity < ApplicationRecord
  include N8nBroadcastable

  KINDS = %w[call email meeting note task].freeze

  belongs_to :contact
  belongs_to :deal, optional: true
  belongs_to :user, optional: true

  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :subject, presence: true, length: { maximum: 500 }

  before_validation :stamp_time

  private

  def stamp_time
    self.occurred_at ||= Time.current
  end
end
