# Seller-chosen order of the product's image attachments (array of
# active_storage_attachments ids). The first image is used as the cover.
class AddImageOrderToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :image_order, :json, null: false, default: []
  end
end
