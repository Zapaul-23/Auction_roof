require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "generates slug from name" do
    category = Category.create!(name: "  Home & Garden ")
    assert_equal "Home & Garden", category.name
    assert_equal "home-garden", category.slug
  end

  test "name must be unique ignoring case" do
    assert_not Category.new(name: "electronics").valid?
  end

  test "cannot delete a category that still has products" do
    category = categories(:electronics)
    assert_not category.destroy
    assert Category.exists?(category.id)
  end

  test "ordered sorts by name" do
    assert_equal %w[ Electronics Fashion ], Category.ordered.map(&:name)
  end
end
