require "test_helper"

class Seller::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "requires sign in" do
    sign_out
    get seller_products_path
    assert_redirected_to new_session_path
  end

  test "lists only my products with status" do
    get seller_products_path

    assert_response :success
    assert_select "##{dom_id(products(:camera))}", /Vintage film camera/
    assert_select "##{dom_id(products(:camera))} .status", "Draft"
    assert_select "##{dom_id(products(:watch))}", count: 0
  end

  test "filters by status" do
    get seller_products_path(status: "published")

    assert_response :success
    assert_select ".seller-product", count: 0
    assert_select ".empty-state"
  end

  test "deletes a draft" do
    assert_difference "Product.count", -1 do
      delete seller_product_path(products(:camera))
    end
    assert_redirected_to seller_products_path
  end

  test "does not delete a published product" do
    sign_in_as users(:two)

    assert_no_difference "Product.count" do
      delete seller_product_path(products(:watch))
    end
    assert_redirected_to seller_products_path
    assert_equal "Unpublish this product before deleting it.", flash[:alert]
  end

  test "cannot delete another seller's product" do
    assert_no_difference "Product.count" do
      delete seller_product_path(products(:watch))
    end
    assert_response :not_found
  end
end
