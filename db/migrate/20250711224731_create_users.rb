class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, null: false, unique: true
      t.string :password_digest, null: false
      t.string :nickname, null: false
      t.string :line_uid
      t.boolean :line_notification_on, null: false, default: false

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
