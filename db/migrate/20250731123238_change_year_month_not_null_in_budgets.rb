class ChangeYearMonthNotNullInBudgets < ActiveRecord::Migration[7.0]
  def change
    change_column_null :budgets, :year_month, false
  end
end
