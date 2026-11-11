class AddStatusToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :status, :string, null: false, default: "draft"
    add_column :products, :published_at, :datetime
    add_index :products, [ :status, :published_at ]
  end
end
