# frozen_string_literal: true

class FormField < ApplicationRecord
  FIELD_TYPES = %w[text textarea email phone select].freeze

  belongs_to :form
  has_many :form_answers, dependent: :destroy

  validates :label, presence: true
  validates :field_type, inclusion: { in: FIELD_TYPES }

  def select?
    field_type == "select"
  end

  def email?
    field_type == "email" || label.to_s.downcase.include?("email")
  end

  def options_list
    Array(options).map(&:to_s).map(&:strip).reject(&:blank?)
  end
end

