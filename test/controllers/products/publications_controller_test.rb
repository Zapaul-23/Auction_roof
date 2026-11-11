require "test_helper"

class Products::PublicationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:camera)
    sign_in_as users(:one)
  end

  test "review page lists what is missing" do
    get new_product_publication_path(@product)

    assert_response :success
    assert_select ".form-errors li", /at least one photo/
    assert_select "button[disabled]", "Publish"
  end

  test "publish a complete draft" do
    @product.images.attach(io: file_fixture("photo.png").open, filename: "photo.png")

    post product_publication_path(@product)

    assert_redirected_to new_product_publication_path(@product)
    assert @product.reload.published?
  end

  test "publishing an incomplete draft fails" do
    post product_publication_path(@product)

    assert_response :unprocessable_entity
    assert @product.reload.draft?
  end

  test "unpublish" do
    sign_in_as users(:two)
    delete product_publication_path(products(:watch))

    assert_redirected_to new_product_publication_path(products(:watch))
    assert products(:watch).reload.draft?
  end

  test "cannot publish another seller's product" do
    post product_publication_path(products(:watch))
    assert_response :not_found
  end

  test "published products cannot be edited until unpublished" do
    sign_in_as users(:two)
    get product_step_path(products(:watch), "details")

    assert_redirected_to new_product_publication_path(products(:watch))
  end
end
