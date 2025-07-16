class RenameDrawDatesToDrawDaysInBudgets < ActiveRecord::Migration[7.0]
  def change
    rename_column :budgets, :draw_dates, :draw_days
  end
end
