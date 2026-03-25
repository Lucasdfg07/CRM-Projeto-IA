# frozen_string_literal: true

class FormResponse < ApplicationRecord
  belongs_to :form
  belongs_to :contact, optional: true
  belongs_to :segment, optional: true

  has_many :form_answers, dependent: :destroy

  validates :submitted_at, presence: true
end

