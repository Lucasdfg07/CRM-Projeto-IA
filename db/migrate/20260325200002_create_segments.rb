class CreateSegments < ActiveRecord::Migration[7.1]
  def change
    create_table :segments do |t|
      t.string  :name,        null: false
      t.text    :description
      t.string  :color,       default: "#6366f1"
      t.timestamps
    end

    create_table :contact_segments, id: false do |t|
      t.integer :contact_id, null: false
      t.integer :segment_id, null: false
      t.datetime :created_at, null: false
    end

    add_index :contact_segments, [:contact_id, :segment_id], unique: true
    add_index :contact_segments, :segment_id
    add_foreign_key :contact_segments, :contacts, on_delete: :cascade
    add_foreign_key :contact_segments, :segments, on_delete: :cascade
  end
end
