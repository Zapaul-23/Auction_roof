require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_registration_path
    assert_response :success
  end

  test "create signs the new user in" do
    assert_difference "User.count", 1 do
      post registration_path, params: { user: { name: "New Seller", email_address: "NEW@example.com",
                                                password: "secret123", password_confirmation: "secret123" } }
    end

    assert_redirected_to root_url
    assert cookies[:session_id]
    assert_equal "new@example.com", User.last.email_address
  end

  test "create with invalid data re-renders the form" do
    assert_no_difference "User.count" do
      post registration_path, params: { user: { name: "", email_address: "one@example.com",
                                                password: "short", password_confirmation: "nope" } }
    end

    assert_response :unprocessable_entity
  end
end
