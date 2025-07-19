class CreateDraws < ActiveRecord::Migration[7.0]
  def change
    create_table :draws do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date
      t.integer :amount
      t.boolean :used
      t.boolean :carried_over

      t.timestamps
    end
  end
end
