require "test_helper"

class Products::StepsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:camera)
    sign_in_as users(:one)
  end

  test "shows each step" do
    @product.images.attach(io: file_fixture("photo.png").open, filename: "photo.png")

    Product::STEPS.each do |step|
      get product_step_path(@product, step)
      assert_response :success
    end
  end

  test "unknown step is not found" do
    get product_step_path(@product, "shipping")
    assert_response :not_found
  end

  test "cannot open another seller's product" do
    get product_step_path(products(:watch), "details")
    assert_response :not_found
  end

  test "cannot use an unknown product" do
    get product_step_path(id: "details", product_id: 0)
    assert_response :not_found
  end

  test "requires sign in" do
    sign_out
    get product_step_path(@product, "details")
    assert_redirected_to new_session_path
  end

  test "updating details goes to the next step" do
    patch product_step_path(@product, "details"), params: { product: { title: "Rangefinder camera" } }

    assert_redirected_to product_step_path(@product, Product.next_step(:details))
    assert_equal "Rangefinder camera", @product.reload.title
  end

  test "images step uploads photos and keeps existing ones" do
    @product.images.attach(io: file_fixture("photo.png").open, filename: "existing.png")

    patch product_step_path(@product, "images"),
          params: { product: { images: [ fixture_file_upload("photo.png", "image/png") ] } }

    assert_redirected_to product_step_path(@product, "pricing")
    assert_equal 2, @product.reload.images.count
  end

  test "images step requires at least one photo" do
    patch product_step_path(@product, "images"), params: { product: { images: [ "" ] } }

    assert_response :unprocessable_entity
    assert_select ".form-errors", /at least one photo/
  end

  test "images step rejects non-image files" do
    patch product_step_path(@product, "images"),
          params: { product: { images: [ fixture_file_upload("notes.txt", "text/plain") ] } }

    assert_response :unprocessable_entity
    assert_equal 0, @product.reload.images.count
  end

  test "pricing step requires a starting price" do
    patch product_step_path(@product, "pricing"), params: { product: { starting_price: "", reserve_price: "" } }

    assert_response :unprocessable_entity
    assert_select ".form-errors", /Starting price can't be blank/
  end

  test "pricing rejects a reserve below the starting price" do
    patch product_step_path(@product, "pricing"), params: { product: { starting_price: 500, reserve_price: 100 } }

    assert_response :unprocessable_entity
  end

  test "save draft keeps progress without requiring the step" do
    patch product_step_path(@product, "pricing"),
          params: { save_draft: "1", product: { starting_price: "", reserve_price: "" } }

    assert_redirected_to root_path
    assert_nil @product.reload.starting_price
    assert @product.draft?
  end

  test "saving the last step goes to review" do
    patch product_step_path(@product, "pricing"), params: { product: { starting_price: 800, reserve_price: "" } }

    assert_redirected_to new_product_publication_path(@product)
    @product.reload
    assert_equal 800, @product.starting_price
    assert_nil @product.reserve_price
  end
end
