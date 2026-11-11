class ProductsController < ApplicationController
  allow_unauthenticated_access only: %i[ index ]

  def index
    @products = Product.includes(:seller).order(created_at: :desc)
  end
end
