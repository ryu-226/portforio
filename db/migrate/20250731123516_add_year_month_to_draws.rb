class AddYearMonthToDraws < ActiveRecord::Migration[7.0]
  def change
    add_column :draws, :year_month, :string
  end
end
