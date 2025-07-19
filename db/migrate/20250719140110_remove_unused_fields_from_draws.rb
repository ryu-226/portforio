class RemoveUnusedFieldsFromDraws < ActiveRecord::Migration[7.0]
  def change
    remove_column :draws, :used, :boolean
    remove_column :draws, :carried_over, :boolean
  end
end
