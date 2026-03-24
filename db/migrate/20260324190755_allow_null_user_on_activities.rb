class AllowNullUserOnActivities < ActiveRecord::Migration[7.1]
  def change
    change_column_null :activities, :user_id, true
  end
end
