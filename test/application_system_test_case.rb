require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ] do |options|
    # Chrome's "save password?" prompt after signing in steals keyboard input.
    options.add_preference("credentials_enable_service", false)
    options.add_preference("profile.password_manager_enabled", false)
    options.add_argument("--disable-features=PasswordManagerOnboarding,PasswordLeakDetection")
    options.add_argument("--incognito")
  end

  def sign_in_with(user, password: "password")
    visit new_session_path
    fill_in "Email", with: user.email_address
    fill_in "Password", with: password
    click_button "Sign in"
    assert_button "Sign out"
  end
end
