# Walks a seller through the "create product" wizard (see Product::STEPS).
# Every step edits the same, already-saved product.
class Products::StepsController < ApplicationController
  before_action :set_product
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

    if @product.save(context: @step.to_sym)
      redirect_to after_step_path
    else
      render :show, status: :unprocessable_entity
    end
  end

  private
    def set_product
      @product = Current.user.products.find(params[:product_id])
    end

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

    def after_step_path
      if (next_step = Product.next_step(@step))
        product_step_path(@product, next_step)
      else
        flash[:notice] = "Product saved."
        root_path
      end
    end
end
