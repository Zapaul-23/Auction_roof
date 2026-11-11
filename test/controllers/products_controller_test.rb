require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "index is public and only lists published products" do
    get root_url

    assert_response :success
    assert_match products(:watch).title, response.body
    assert_no_match products(:camera).title, response.body
  end

  test "show a published product to anyone" do
    product = products(:watch)
    2.times { product.images.attach(io: file_fixture("photo.png").open, filename: "photo.png") }

    get product_path(product)

    assert_response :success
    assert_select "h1", product.title
    assert_select ".price", /5,000/
    assert_select ".product-gallery-thumbs button", 2
    assert_select ".seller-box", /Suda Seller/
    assert_select ".seller-box", /1 live listing/
    assert_no_match "Reserve price set", response.body
  end

  test "draft products are hidden from the public" do
    get product_path(products(:camera))
    assert_response :not_found
  end

  test "draft products are hidden from other sellers" do
    sign_in_as users(:two)
    get product_path(products(:camera))
    assert_response :not_found
  end

  test "seller can preview their own draft" do
    sign_in_as users(:one)
    get product_path(products(:camera))

    assert_response :success
    assert_select ".flash", /preview of your draft/
    assert_select ".price-box", /Reserve price set/
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
