require "test_helper"

class Product::ImagesTest < ActiveSupport::TestCase
  setup { @product = products(:camera) }

  def attach(name = "photo.png", content_type: "image/png", io: nil)
    @product.images.attach(io: io || file_fixture(name).open, filename: name, content_type: content_type)
  end

  test "accepts png images" do
    assert attach
    assert_equal 1, @product.images.count
  end

  test "rejects files that are not images" do
    assert_not attach("notes.txt", content_type: "text/plain")
    assert @product.errors[:images].any? { |message| message.include?("must be a JPG, PNG or WebP") }
  end

  test "rejects images that are too large" do
    big = StringIO.new(file_fixture("photo.png").binread + ("0" * (Product::MAX_IMAGE_SIZE + 1)))
    assert_not attach(io: big)
    assert @product.errors[:images].any? { |message| message.include?("larger than") }
  end

  test "limits the number of images" do
    Product::MAX_IMAGES.times { assert attach }
    assert_not attach
  end

  test "images step requires at least one photo" do
    assert_not @product.valid?(:images)
    attach
    assert @product.valid?(:images)
  end

  test "orders images and lets the seller move them" do
    3.times { attach }
    first, second, third = @product.ordered_images.map(&:id)

    @product.move_image(third, :up)
    assert_equal [ first, third, second ], @product.reload.ordered_images.map(&:id)

    @product.move_image(first, :down)
    assert_equal [ third, first, second ], @product.reload.ordered_images.map(&:id)
    assert_equal third, @product.cover_image.id
  end

  test "cannot move past either end" do
    2.times { attach }
    first, last = @product.ordered_images.map(&:id)

    assert_not @product.move_image(first, :up)
    assert_not @product.move_image(last, :down)
  end
end
