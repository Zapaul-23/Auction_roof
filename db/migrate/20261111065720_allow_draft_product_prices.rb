# Products are created step by step (details -> images -> pricing), so the
# price is not known when the record is first saved.
class AllowDraftProductPrices < ActiveRecord::Migration[8.1]
  def change
    change_column_null :products, :starting_price, true
  end
end
