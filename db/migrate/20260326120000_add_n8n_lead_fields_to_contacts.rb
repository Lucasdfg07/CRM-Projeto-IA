# frozen_string_literal: true

class AddN8nLeadFieldsToContacts < ActiveRecord::Migration[7.1]
  def change
    add_column :contacts, :lead_temperature, :string
    add_column :contacts, :lead_metadata, :json, null: false, default: {}
    add_column :contacts, :phone_normalized, :string
    add_column :contacts, :external_source_id, :string

    add_index :contacts, %i[company_id phone_normalized],
      unique: true,
      where: "phone_normalized IS NOT NULL",
      name: "index_contacts_on_company_id_and_phone_normalized"

    add_index :contacts, %i[company_id external_source_id],
      unique: true,
      where: "external_source_id IS NOT NULL",
      name: "index_contacts_on_company_id_and_external_source_id"
  end
end
