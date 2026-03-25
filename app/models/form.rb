# frozen_string_literal: true

class Form < ApplicationRecord
  THEMES = %w[neo].freeze

  belongs_to :target_segment, class_name: "Segment", optional: true
  has_many :form_fields, -> { order(position: :asc) }, dependent: :destroy
  has_many :form_responses, dependent: :destroy

  accepts_nested_attributes_for :form_fields, allow_destroy: true

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :theme, inclusion: { in: THEMES }
  validates :accent_color, format: { with: /\A#[0-9a-fA-F]{6}\z/, message: "deve ser um hex válido (#rrggbb)" }

  before_validation :ensure_slug

  scope :enabled, -> { where(enabled: true) }
  scope :by_recent, -> { order(created_at: :desc) }

  def public_path
    "/f/#{slug}"
  end

  private

  def ensure_slug
    return if slug.present?
    base = name.to_s.parameterize.presence || "form"
    self.slug = "#{base}-#{SecureRandom.hex(3)}"
  end
end

