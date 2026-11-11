class ProductsController < ApplicationController
  allow_unauthenticated_access only: %i[ index ]

  def index
    @products = Product.where.not(starting_price: nil).includes(:seller, :category).order(created_at: :desc)
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
