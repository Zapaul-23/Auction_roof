class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :condition, null: false, default: "used"
      t.decimal :starting_price, precision: 12, scale: 2, null: false
      t.decimal :reserve_price, precision: 12, scale: 2
      t.references :seller, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
