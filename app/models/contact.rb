# frozen_string_literal: true

class Contact < ApplicationRecord
  include N8nBroadcastable

  LIFECYCLES = %w[lead prospect customer churned].freeze
  LEAD_TEMPERATURES = %w[frio morno quente].freeze

  belongs_to :company
  has_many :deals, dependent: :nullify
  has_many :activities, dependent: :destroy
  has_and_belongs_to_many :segments,
    join_table: :contact_segments,
    foreign_key: :contact_id

  validates :first_name, presence: true
  validates :lifecycle_stage, inclusion: { in: LIFECYCLES }, allow_blank: true
  validates :lead_temperature, inclusion: { in: LEAD_TEMPERATURES }, allow_blank: true

  before_validation :default_lifecycle
  before_validation :normalize_email_field
  before_validation :sync_phone_normalized

  def full_name
    [first_name, last_name].compact_blank.join(" ").presence || email.presence || "Contato ##{id}"
  end

  # Apenas dígitos; para BR remove 55 inicial (13 dígitos) para bater com números salvos só com DDD.
  def self.normalize_phone(phone)
    return nil if phone.blank?

    digits = phone.to_s.gsub(/\D/, "")
    return nil if digits.blank?

    if digits.length >= 12 && digits.start_with?("55") && digits.length <= 13
      digits = digits[2..]
    end

    digits.presence
  end

  # Para encontrar contatos gravados antes da normalização (com ou sem 55).
  def self.phone_lookup_keys(phone)
    n = normalize_phone(phone)
    return [] if n.blank?

    keys = [n]
    keys << "55#{n}" if n.length.between?(10, 11)
    keys.uniq
  end

  def self.normalize_email_string(email)
    email.to_s.strip.downcase.presence
  end

  private

  def default_lifecycle
    self.lifecycle_stage ||= "lead"
  end

  def normalize_email_field
    self.email = self.class.normalize_email_string(email)
  end

  def sync_phone_normalized
    self.phone_normalized = phone.present? ? self.class.normalize_phone(phone) : nil
  end
end
