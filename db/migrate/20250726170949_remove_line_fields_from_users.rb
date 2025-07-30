class RemoveLineFieldsFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :line_uid, :string
    remove_column :users, :line_notification_on, :boolean
  end
end
