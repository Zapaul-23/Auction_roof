# Remove or reorder a single photo of the seller's product.
class Products::ImagesController < ApplicationController
  before_action :set_product
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
    def set_product
      @product = Current.user.products.find(params[:product_id])
    end

    def set_image
      @image = @product.images.attachments.find(params[:id])
    end
end
