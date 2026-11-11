# Walks a seller through the "create product" wizard (see Product::STEPS).
# Every step edits the same, already-saved draft product.
class Products::StepsController < ApplicationController
  include SellerProduct

  before_action :set_seller_product
  before_action :require_draft
  before_action :set_step

  def show
  end

  def update
    if @step == "images"
      # Add the new uploads to the existing ones instead of replacing them.
      @product.images.attach(new_images) if new_images.any?
    else
      @product.assign_attributes(step_params)
    end

    # "Save draft" keeps whatever is valid so far; "Next" requires the step to be complete.
    if @product.save(context: saving_draft? ? nil : @step.to_sym)
      redirect_to after_step_path
    else
      render :show, status: :unprocessable_entity
    end
  end

  private
    def set_step
      @step = params[:id]
      raise ActiveRecord::RecordNotFound, "Unknown step" unless Product::STEPS.include?(@step)
    end

    def step_params
      case @step
      when "details" then params.expect(product: %i[ title description category_id condition ])
      when "pricing" then params.expect(product: %i[ starting_price reserve_price ])
      end
    end

    def new_images
      @new_images ||= Array(params.dig(:product, :images)).compact_blank
    end

    def saving_draft?
      params[:save_draft].present?
    end

    def after_step_path
      if saving_draft?
        flash[:notice] = "Draft saved. You can continue later."
        seller_products_path
      elsif (next_step = Product.next_step(@step))
        product_step_path(@product, next_step)
      else
        new_product_publication_path(@product)
      end
    end
end
