require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def build_product(**attrs)
    Product.new({ title: "Lamp", description: "Desk lamp", condition: "used",
                  starting_price: 100, seller: users(:one) }.merge(attrs))
  end

  test "fixture is valid" do
    assert products(:camera).valid?
  end

  test "requires title and description" do
    product = build_product(title: "", description: "")
    assert_not product.valid?
    assert product.errors.added?(:title, :blank)
    assert product.errors.added?(:description, :blank)
  end

  test "starting price must be greater than zero" do
    assert_not build_product(starting_price: 0).valid?
    assert_not build_product(starting_price: -5).valid?
    assert_not build_product(starting_price: nil).valid?
    assert build_product(starting_price: 0.01).valid?
  end

  test "reserve price is optional but cannot be below starting price" do
    assert build_product(reserve_price: nil).valid?
    assert build_product(reserve_price: 100).valid?
    assert_not build_product(reserve_price: 99).valid?
  end

  test "condition must be a known value" do
    assert_not build_product(condition: "broken").valid?
  end

  test "belongs to a seller" do
    assert_not build_product(seller: nil).valid?
    assert_equal users(:one), products(:camera).seller
    assert_includes users(:one).products, products(:camera)
  end
end
