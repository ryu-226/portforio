class CreateBudgets < ActiveRecord::Migration[7.0]
  def change
    create_table :budgets do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :monthly_budget, null: false
      t.integer :draw_days, null: false
      t.integer :min_amount, null: false
      t.integer :max_amount, null: false

      t.timestamps
    end
  end
end
