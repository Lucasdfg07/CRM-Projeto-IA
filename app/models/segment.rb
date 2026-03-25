# frozen_string_literal: true

class Segment < ApplicationRecord
  has_and_belongs_to_many :contacts,
    join_table: :contact_segments,
    association_foreign_key: :contact_id

  has_and_belongs_to_many :campaigns,
    join_table: :campaign_segments,
    association_foreign_key: :campaign_id

  validates :name,  presence: true, uniqueness: { case_sensitive: false }
  validates :color, format: { with: /\A#[0-9a-fA-F]{6}\z/, message: "deve ser um hex válido (#rrggbb)" }

  def contacts_count
    contacts.count
  end
end
