# Review a product, then publish it (draft -> published) or take it back down.
class Products::PublicationsController < ApplicationController
  include SellerProduct

  before_action :set_seller_product

  def new
    @blockers = @product.draft? ? @product.publish_blockers : []
  end

  def create
    if @product.publish
      redirect_to new_product_publication_path(@product), notice: "Your product is now live."
    else
      @blockers = @product.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @product.unpublish
    redirect_to new_product_publication_path(@product), notice: "Product moved back to drafts."
  end
end
