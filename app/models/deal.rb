# frozen_string_literal: true

class Deal < ApplicationRecord
  include N8nBroadcastable

  STAGES = %w[qualification proposal negotiation won lost].freeze

  belongs_to :company
  belongs_to :contact, optional: true

  validates :name, presence: true
  validates :stage, inclusion: { in: STAGES }, allow_blank: true
  validates :currency, length: { maximum: 8 }, allow_blank: true

  before_validation :defaults

  def amount_decimal
    return if amount_cents.nil?

    amount_cents / 100.0
  end

  def amount_reais_for_form
    return "" if amount_cents.nil?

    format("%.2f", amount_cents / 100.0)
  end

  private

  def defaults
    self.stage ||= "qualification"
    self.currency ||= "BRL"
    self.probability ||= 10
  end
end
