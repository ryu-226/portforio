class RemoveYearMonthFromDraws < ActiveRecord::Migration[7.0]
  def up
    remove_column :draws, :year_month, :string
  end
  def down
    add_column :draws, :year_month, :string
  end
end
