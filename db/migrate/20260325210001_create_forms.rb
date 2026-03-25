class CreateForms < ActiveRecord::Migration[7.1]
  def change
    create_table :forms do |t|
      t.string  :name, null: false
      t.text    :description
      t.string  :slug, null: false
      t.string  :theme, default: "neo"
      t.string  :accent_color, default: "#22d3ee"
      t.integer :target_segment_id
      t.boolean :enabled, default: true
      t.timestamps
    end

    add_index :forms, :slug, unique: true
    add_foreign_key :forms, :segments, column: :target_segment_id

    create_table :form_fields do |t|
      t.integer :form_id, null: false
      t.string  :label, null: false
      t.string  :field_type, null: false, default: "text"
      t.boolean :required, default: false
      t.integer :position, default: 0
      t.text    :placeholder
      t.json    :options
      t.timestamps
    end

    add_index :form_fields, [:form_id, :position]
    add_foreign_key :form_fields, :forms, on_delete: :cascade

    create_table :form_responses do |t|
      t.integer  :form_id, null: false
      t.integer  :contact_id
      t.integer  :segment_id
      t.string   :email
      t.string   :ip
      t.string   :user_agent
      t.datetime :submitted_at
      t.timestamps
    end

    add_index :form_responses, :form_id
    add_index :form_responses, :contact_id
    add_foreign_key :form_responses, :forms, on_delete: :cascade
    add_foreign_key :form_responses, :contacts, on_delete: :nullify
    add_foreign_key :form_responses, :segments, column: :segment_id, on_delete: :nullify

    create_table :form_answers do |t|
      t.integer :form_response_id, null: false
      t.integer :form_field_id, null: false
      t.text    :value
      t.timestamps
    end

    add_index :form_answers, :form_response_id
    add_index :form_answers, [:form_field_id, :form_response_id], unique: true
    add_foreign_key :form_answers, :form_responses, on_delete: :cascade
    add_foreign_key :form_answers, :form_fields, on_delete: :cascade
  end
end

