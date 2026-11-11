require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "index is public" do
    get root_url
    assert_response :success
  end
end
