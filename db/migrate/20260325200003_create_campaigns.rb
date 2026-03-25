class CreateCampaigns < ActiveRecord::Migration[7.1]
  def change
    create_table :campaigns do |t|
      t.string   :name,              null: false
      t.string   :subject,           null: false
      t.string   :preview_text
      t.text     :html_body
      t.string   :status,            default: "draft"
      t.integer  :email_provider_id
      t.string   :from_name
      t.string   :from_email
      t.string   :reply_to
      t.datetime :scheduled_at
      t.datetime :sent_at
      t.integer  :total_recipients,  default: 0
      t.integer  :delivered_count,   default: 0
      t.integer  :failed_count,      default: 0
      t.timestamps
    end

    create_table :campaign_segments, id: false do |t|
      t.integer :campaign_id, null: false
      t.integer :segment_id,  null: false
    end

    add_index :campaign_segments, [:campaign_id, :segment_id], unique: true
    add_foreign_key :campaign_segments, :campaigns, on_delete: :cascade
    add_foreign_key :campaign_segments, :segments,  on_delete: :cascade

    create_table :campaign_recipients do |t|
      t.integer  :campaign_id,   null: false
      t.integer  :contact_id
      t.string   :email,         null: false
      t.string   :contact_name
      t.string   :status,        default: "pending"
      t.datetime :sent_at
      t.string   :error_message
      t.timestamps
    end

    add_index :campaign_recipients, :campaign_id
    add_index :campaign_recipients, :status
    add_foreign_key :campaign_recipients, :campaigns, on_delete: :cascade
  end
end
