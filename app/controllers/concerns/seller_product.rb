# Loads one of the signed-in seller's own products. Only drafts can be edited;
# a published product has to be unpublished first.
module SellerProduct
  extend ActiveSupport::Concern

  private
    def set_seller_product
      @product = Current.user.products.find(params[:product_id])
    end

    def require_draft
      return if @product.draft?

      redirect_to new_product_publication_path(@product), alert: "Unpublish this product before editing it."
    end
end
