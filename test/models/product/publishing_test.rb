require "test_helper"

class Product::PublishingTest < ActiveSupport::TestCase
  setup { @product = products(:camera) }

  def attach_photo
    @product.images.attach(io: file_fixture("photo.png").open, filename: "photo.png")
  end

  test "new products start as drafts" do
    product = Product.new
    assert product.draft?
  end

  test "cannot publish without photos" do
    assert_not @product.publish
    assert @product.reload.draft?
    assert_nil @product.published_at
    assert_includes @product.publish_blockers, "Images must include at least one photo"
  end

  test "cannot publish without a starting price" do
    attach_photo
    @product.update!(starting_price: nil)

    assert_not @product.publishable?
    assert_not @product.publish
    assert @product.reload.draft?
  end

  test "publishes a complete draft" do
    attach_photo
    assert @product.publishable?

    freeze_time do
      assert @product.publish
      assert @product.reload.published?
      assert_equal Time.current, @product.published_at
    end
  end

  test "unpublish moves it back to drafts" do
    product = products(:watch)
    assert product.unpublish
    assert product.reload.draft?
    assert_nil product.published_at
  end

  test "live only lists published products" do
    assert_equal [ products(:watch) ], Product.live.to_a
  end
end
