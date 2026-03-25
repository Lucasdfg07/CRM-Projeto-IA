# frozen_string_literal: true

class FormAnswer < ApplicationRecord
  belongs_to :form_response
  belongs_to :form_field

  validates :value, presence: true, if: -> { form_field&.required? }
end

