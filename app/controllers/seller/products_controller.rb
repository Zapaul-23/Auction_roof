# The signed-in seller's own products, drafts and published.
class Seller::ProductsController < ApplicationController
  def index
    @status = params[:status].presence_in(Product.statuses.keys)
    products = Current.user.products.includes(:category, images_attachments: :blob).order(updated_at: :desc)
    @counts = Current.user.products.group(:status).count
    @products = @status ? products.where(status: @status) : products
  end

  def destroy
    product = Current.user.products.find(params[:id])

    if product.draft?
      product.destroy!
      redirect_to seller_products_path, notice: "Draft deleted.", status: :see_other
    else
      redirect_to seller_products_path, alert: "Unpublish this product before deleting it.", status: :see_other
    end
  end
end
