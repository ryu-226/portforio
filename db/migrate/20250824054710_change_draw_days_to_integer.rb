class ChangeDrawDaysToInteger < ActiveRecord::Migration[7.0]
  def up
    # text → integer（PostgreSQL。既存値を整数にキャスト）
    change_column :budgets, :draw_days, :integer, null: false, using: 'draw_days::integer'

    # 下限チェック（0禁止）
    add_check_constraint :budgets, 'draw_days > 0', name: 'chk_budgets_draw_days_positive'
  end

  def down
    remove_check_constraint :budgets, name: 'chk_budgets_draw_days_positive'
    change_column :budgets, :draw_days, :text, null: false
  end
end
