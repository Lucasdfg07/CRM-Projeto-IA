class CreateDeals < ActiveRecord::Migration[7.1]
  def change
    create_table :deals do |t|
      t.references :company, null: false, foreign_key: true
      t.references :contact, foreign_key: true
      t.string :name
      t.integer :amount_cents
      t.string :currency
      t.string :stage
      t.integer :probability
      t.date :expected_close_on

      t.timestamps
    end
  end
end
