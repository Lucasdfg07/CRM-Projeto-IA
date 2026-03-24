# frozen_string_literal: true

class User < ApplicationRecord
  ROLES = %w[admin member].freeze

  has_secure_password

  has_many :activities, dependent: :nullify

  before_validation :apply_default_role

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: ROLES }

  def admin?
    role == "admin"
  end

  def apply_default_role
    self.role ||= "member"
  end
end
