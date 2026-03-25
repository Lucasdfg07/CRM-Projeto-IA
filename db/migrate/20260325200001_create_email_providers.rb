class CreateEmailProviders < ActiveRecord::Migration[7.1]
  def change
    create_table :email_providers do |t|
      t.string  :name,          null: false
      t.string  :provider_type, null: false, default: "smtp"
      t.string  :host
      t.integer :port,          default: 587
      t.string  :username
      t.string  :encrypted_smtp_password
      t.string  :from_name
      t.string  :from_email
      t.boolean :ssl,           default: false
      t.boolean :starttls,      default: true
      t.boolean :is_default,    default: false
      t.boolean :enabled,       default: true
      t.timestamps
    end
  end
end
