# frozen_string_literal: true

class User < ApplicationRecord
  ROLES = %w[admin member].freeze

  # Senha mínima de 12 caracteres
  PASSWORD_MIN_LENGTH = 12

  has_secure_password

  has_many :activities, dependent: :nullify

  before_validation :apply_default_role

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :role, inclusion: { in: ROLES }

  # Valida senha forte apenas quando uma nova senha é fornecida
  validates :password, length: { minimum: PASSWORD_MIN_LENGTH }, allow_nil: true
  validate :password_complexity, if: -> { password.present? }

  def admin?
    role == "admin"
  end

  private

  def apply_default_role
    self.role ||= "member"
  end

  # ---------------------------------------------------------------------------
  # Política de senha forte:
  # - Pelo menos 1 letra maiúscula
  # - Pelo menos 1 letra minúscula
  # - Pelo menos 1 número
  # - Pelo menos 1 caractere especial
  # ---------------------------------------------------------------------------
  def password_complexity
    return if password.blank?

    errors.add(:password, "deve conter pelo menos uma letra maiúscula") unless password.match?(/[A-Z]/)
    errors.add(:password, "deve conter pelo menos uma letra minúscula") unless password.match?(/[a-z]/)
    errors.add(:password, "deve conter pelo menos um número")           unless password.match?(/\d/)
    errors.add(:password, "deve conter pelo menos um caractere especial (@, #, $, !, %, &, *, etc.)") unless password.match?(/[\W_]/)
  end
end
