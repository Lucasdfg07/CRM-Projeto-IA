# frozen_string_literal: true

class Company < ApplicationRecord
  include N8nBroadcastable

  has_many :contacts, dependent: :destroy
  has_many :deals, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
end
