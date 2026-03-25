# frozen_string_literal: true

class AddRecipientFilterToCampaigns < ActiveRecord::Migration[7.1]
  def change
    add_column :campaigns, :recipient_filter, :string, null: false, default: "email"
  end
end
