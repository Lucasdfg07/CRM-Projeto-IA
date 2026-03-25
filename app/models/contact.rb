# frozen_string_literal: true

class Contact < ApplicationRecord
  include N8nBroadcastable

  LIFECYCLES = %w[lead prospect customer churned].freeze

  belongs_to :company
  has_many :deals, dependent: :nullify
  has_many :activities, dependent: :destroy
  has_and_belongs_to_many :segments,
    join_table: :contact_segments,
    foreign_key: :contact_id

  validates :first_name, presence: true
  validates :lifecycle_stage, inclusion: { in: LIFECYCLES }, allow_blank: true

  before_validation :default_lifecycle

  def full_name
    [first_name, last_name].compact_blank.join(" ").presence || email.presence || "Contato ##{id}"
  end

  private

  def default_lifecycle
    self.lifecycle_stage ||= "lead"
  end
end
