require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "requires name, unique email and a long enough password" do
    user = User.new(name: "", email_address: "one@example.com", password: "short")
    assert_not user.valid?
    assert user.errors.added?(:name, :blank)
    assert user.errors.added?(:email_address, :taken, value: "one@example.com")
    assert user.errors.of_kind?(:password, :too_short)
  end
end
