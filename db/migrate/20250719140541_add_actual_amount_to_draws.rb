class AddActualAmountToDraws < ActiveRecord::Migration[7.0]
  def change
    add_column :draws, :actual_amount, :integer
  end
end
