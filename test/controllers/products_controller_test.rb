require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "index is public" do
    get root_url
    assert_response :success
  end

  test "new requires sign in" do
    get new_product_path
    assert_redirected_to new_session_path
  end

  test "create requires sign in" do
    assert_no_difference "Product.count" do
      post products_path, params: { product: { title: "x" } }
    end
    assert_redirected_to new_session_path
  end

  test "new shows the details step with categories" do
    sign_in_as users(:one)
    get new_product_path

    assert_response :success
    assert_select "select[name='product[category_id]'] option", text: "Electronics"
  end

  test "create saves details and moves to the next step" do
    sign_in_as users(:one)

    assert_difference "users(:one).products.count", 1 do
      post products_path, params: { product: { title: "Guitar", description: "Acoustic guitar",
                                               category_id: categories(:electronics).id, condition: "used" } }
    end

    product = Product.order(:id).last
    assert_nil product.starting_price
    assert_redirected_to product_step_path(product, Product.next_step(:details))
  end

  test "create with missing details shows errors" do
    sign_in_as users(:one)

    assert_no_difference "Product.count" do
      post products_path, params: { product: { title: "", description: "", condition: "used" } }
    end

    assert_response :unprocessable_entity
    assert_select ".form-errors"
  end
end
