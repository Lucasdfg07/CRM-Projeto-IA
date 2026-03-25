# frozen_string_literal: true

class EmailProvider < ApplicationRecord
  PROVIDER_TYPES = %w[smtp gmail hostinger outlook].freeze

  PROVIDER_DEFAULTS = {
    "gmail"     => { host: "smtp.gmail.com",        port: 587, starttls: true,  ssl: false },
    "hostinger" => { host: "smtp.hostinger.com",    port: 587, starttls: true,  ssl: false },
    "outlook"   => { host: "smtp.office365.com",    port: 587, starttls: true,  ssl: false },
    "smtp"      => { host: "",                       port: 587, starttls: true,  ssl: false }
  }.freeze

  has_many :campaigns, dependent: :nullify

  validates :name,          presence: true
  validates :provider_type, inclusion: { in: PROVIDER_TYPES }
  validates :host,          presence: true
  validates :port,          numericality: { only_integer: true, greater_than: 0, less_than: 65_536 }
  validates :username,      presence: true
  validates :from_email,    presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_save :ensure_single_default

  def smtp_password
    return nil if encrypted_smtp_password.blank?
    decrypt(encrypted_smtp_password)
  end

  def smtp_password=(value)
    self.encrypted_smtp_password = value.present? ? encrypt(value) : nil
  end

  def to_mail_settings
    {
      address:              host,
      port:                 port,
      user_name:            username,
      password:             smtp_password,
      authentication:       :plain,
      enable_starttls_auto: starttls?,
      ssl:                  ssl?
    }
  end

  private

  def ensure_single_default
    return unless is_default?
    EmailProvider.where.not(id: id).update_all(is_default: false)
  end

  def encryption_key
    key = ENV.fetch("SECRET_KEY_BASE", Rails.application.secret_key_base)
    key[0, 32].ljust(32, "0")
  end

  def encrypt(value)
    key   = encryption_key
    iv    = OpenSSL::Random.random_bytes(12)
    cipher = OpenSSL::Cipher.new("aes-256-gcm")
    cipher.encrypt
    cipher.key = key
    cipher.iv  = iv
    encrypted  = cipher.update(value) + cipher.final
    tag        = cipher.auth_tag
    Base64.strict_encode64(iv + tag + encrypted)
  end

  def decrypt(encoded)
    raw       = Base64.strict_decode64(encoded)
    iv        = raw[0, 12]
    tag       = raw[12, 16]
    encrypted = raw[28..]
    cipher    = OpenSSL::Cipher.new("aes-256-gcm")
    cipher.decrypt
    cipher.key      = encryption_key
    cipher.iv       = iv
    cipher.auth_tag = tag
    cipher.update(encrypted) + cipher.final
  rescue StandardError
    nil
  end
end
