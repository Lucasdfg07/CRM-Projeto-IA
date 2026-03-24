class CreateActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :activities do |t|
      t.references :contact, null: false, foreign_key: true
      t.references :deal, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :kind
      t.string :subject
      t.text :body
      t.datetime :occurred_at

      t.timestamps
    end
  end
end
