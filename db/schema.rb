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

ActiveRecord::Schema[7.1].define(version: 2026_03_24_190755) do
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

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "sector"
    t.string "website"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  add_foreign_key "contacts", "companies"
  add_foreign_key "deals", "companies"
  add_foreign_key "deals", "contacts"
end
