class AddYearMonthToBudgets < ActiveRecord::Migration[7.0]
  def change
    add_column :budgets, :year_month, :string, null: true
    add_index :budgets, [:user_id, :year_month], unique: true
  end
end
