# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_03_27_100000) do
  create_table "activities", force: :cascade do |t|
    t.integer "contact_id", null: false
    t.integer "deal_id"
    t.integer "user_id"
    t.string "kind"
    t.string "subject"
    t.text "body"
    t.datetime "occurred_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_activities_on_contact_id"
    t.index ["deal_id"], name: "index_activities_on_deal_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "campaign_recipients", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "contact_id"
    t.string "email", null: false
    t.string "contact_name"
    t.string "status", default: "pending"
    t.datetime "sent_at"
    t.string "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_campaign_recipients_on_campaign_id"
    t.index ["status"], name: "index_campaign_recipients_on_status"
  end

  create_table "campaign_segments", id: false, force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "segment_id", null: false
    t.index ["campaign_id", "segment_id"], name: "index_campaign_segments_on_campaign_id_and_segment_id", unique: true
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "name", null: false
    t.string "subject", null: false
    t.string "preview_text"
    t.text "html_body"
    t.string "status", default: "draft"
    t.integer "email_provider_id"
    t.string "from_name"
    t.string "from_email"
    t.string "reply_to"
    t.datetime "scheduled_at"
    t.datetime "sent_at"
    t.integer "total_recipients", default: 0
    t.integer "delivered_count", default: 0
    t.integer "failed_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "recipient_filter", default: "email", null: false
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "sector"
    t.string "website"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contact_segments", id: false, force: :cascade do |t|
    t.integer "contact_id", null: false
    t.integer "segment_id", null: false
    t.datetime "created_at", null: false
    t.index ["contact_id", "segment_id"], name: "index_contact_segments_on_contact_id_and_segment_id", unique: true
    t.index ["segment_id"], name: "index_contact_segments_on_segment_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone"
    t.string "title"
    t.string "lifecycle_stage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "lead_temperature"
    t.json "lead_metadata", default: {}, null: false
    t.string "phone_normalized"
    t.string "external_source_id"
    t.index ["company_id", "external_source_id"], name: "index_contacts_on_company_id_and_external_source_id", unique: true, where: "external_source_id IS NOT NULL"
    t.index ["company_id", "phone_normalized"], name: "index_contacts_on_company_id_and_phone_normalized", unique: true, where: "phone_normalized IS NOT NULL"
    t.index ["company_id"], name: "index_contacts_on_company_id"
  end

  create_table "deals", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "contact_id"
    t.string "name"
    t.integer "amount_cents"
    t.string "currency"
    t.string "stage"
    t.integer "probability"
    t.date "expected_close_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_deals_on_company_id"
    t.index ["contact_id"], name: "index_deals_on_contact_id"
  end

  create_table "email_providers", force: :cascade do |t|
    t.string "name", null: false
    t.string "provider_type", default: "smtp", null: false
    t.string "host"
    t.integer "port", default: 587
    t.string "username"
    t.string "encrypted_smtp_password"
    t.string "from_name"
    t.string "from_email"
    t.boolean "ssl", default: false
    t.boolean "starttls", default: true
    t.boolean "is_default", default: false
    t.boolean "enabled", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "form_answers", force: :cascade do |t|
    t.integer "form_response_id", null: false
    t.integer "form_field_id", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["form_field_id", "form_response_id"], name: "index_form_answers_on_form_field_id_and_form_response_id", unique: true
    t.index ["form_response_id"], name: "index_form_answers_on_form_response_id"
  end

  create_table "form_fields", force: :cascade do |t|
    t.integer "form_id", null: false
    t.string "label", null: false
    t.string "field_type", default: "text", null: false
    t.boolean "required", default: false
    t.integer "position", default: 0
    t.text "placeholder"
    t.json "options"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["form_id", "position"], name: "index_form_fields_on_form_id_and_position"
  end

  create_table "form_responses", force: :cascade do |t|
    t.integer "form_id", null: false
    t.integer "contact_id"
    t.integer "segment_id"
    t.string "email"
    t.string "ip"
    t.string "user_agent"
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_form_responses_on_contact_id"
    t.index ["form_id"], name: "index_form_responses_on_form_id"
  end

  create_table "forms", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "slug", null: false
    t.string "theme", default: "neo"
    t.string "accent_color", default: "#22d3ee"
    t.integer "target_segment_id"
    t.boolean "enabled", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_forms_on_slug", unique: true
  end

  create_table "segments", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "color", default: "#6366f1"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "activities", "contacts"
  add_foreign_key "activities", "deals"
  add_foreign_key "activities", "users"
  add_foreign_key "campaign_recipients", "campaigns", on_delete: :cascade
  add_foreign_key "campaign_segments", "campaigns", on_delete: :cascade
  add_foreign_key "campaign_segments", "segments", on_delete: :cascade
  add_foreign_key "contact_segments", "contacts", on_delete: :cascade
  add_foreign_key "contact_segments", "segments", on_delete: :cascade
  add_foreign_key "contacts", "companies"
  add_foreign_key "deals", "companies"
  add_foreign_key "deals", "contacts"
  add_foreign_key "form_answers", "form_fields", on_delete: :cascade
  add_foreign_key "form_answers", "form_responses", on_delete: :cascade
  add_foreign_key "form_fields", "forms", on_delete: :cascade
  add_foreign_key "form_responses", "contacts", on_delete: :nullify
  add_foreign_key "form_responses", "forms", on_delete: :cascade
  add_foreign_key "form_responses", "segments", on_delete: :nullify
  add_foreign_key "forms", "segments", column: "target_segment_id"
end
