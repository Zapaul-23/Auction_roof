require "test_helper"

class Products::ImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:camera)
    2.times { @product.images.attach(io: file_fixture("photo.png").open, filename: "photo.png") }
    @first, @second = @product.ordered_images
    sign_in_as users(:one)
  end

  test "move changes the order" do
    patch move_product_image_path(@product, @second, direction: "up")

    assert_redirected_to product_step_path(@product, "images")
    assert_equal [ @second.id, @first.id ], @product.reload.ordered_images.map(&:id)
  end

  test "destroy removes the photo" do
    perform_enqueued_jobs do
      delete product_image_path(@product, @first)
    end

    assert_redirected_to product_step_path(@product, "images")
    assert_equal [ @second.id ], @product.reload.ordered_images.map(&:id)
  end

  test "cannot touch another seller's photos" do
    sign_in_as users(:two)
    delete product_image_path(@product, @first)

    assert_response :not_found
    assert_equal 2, @product.reload.images.count
  end
end
