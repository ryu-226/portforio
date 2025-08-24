class AddUniqueIndexOnDrawsUserDate < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!
  def up
    remove_index :draws, [:user_id, :date], if_exists: true
    add_index :draws, [:user_id, :date], unique: true,
                                         algorithm: :concurrently,
                                         name: "index_draws_on_user_id_and_date_unique"
  end
  def down
    remove_index :draws, name: "index_draws_on_user_id_and_date_unique", if_exists: true
  end
end
