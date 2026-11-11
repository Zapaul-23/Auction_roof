# Remove or reorder a single photo of the seller's draft product.
class Products::ImagesController < ApplicationController
  include SellerProduct

  before_action :set_seller_product
  before_action :require_draft
  before_action :set_image

  def destroy
    @image.purge_later
    redirect_back_or_to product_step_path(@product, "images"), notice: "Photo removed."
  end

  def move
    @product.move_image(@image.id, params[:direction] == "up" ? :up : :down)
    redirect_back_or_to product_step_path(@product, "images")
  end

  private
    def set_image
      @image = @product.images.attachments.find(params[:id])
    end
end
