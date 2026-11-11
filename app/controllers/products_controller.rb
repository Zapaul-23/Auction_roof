class ProductsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]

  def index
    @products = Product.live.includes(:category, images_attachments: :blob)
  end

  # Published products are public; a seller may also preview their own draft.
  def show
    resume_session
    @product = Product.includes(:seller, :category, images_attachments: :blob).find(params[:id])
    raise ActiveRecord::RecordNotFound unless @product.published? || @product.seller == Current.user
  end

  # Step 1 of the wizard: product details.
  def new
    @product = Current.user.products.new
  end

  def create
    @product = Current.user.products.new(details_params)

    if @product.save
      redirect_to product_step_path(@product, Product.next_step(:details))
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def details_params
      params.expect(product: %i[ title description category_id condition ])
    end
end
