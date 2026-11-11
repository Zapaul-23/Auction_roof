require "application_system_test_case"

class ProductOnboardingTest < ApplicationSystemTestCase
  test "a new seller signs up, lists a product and publishes it" do
    visit root_path
    within(".site-header") { click_on "Sign up" }

    fill_in "Display name", with: "Niran"
    fill_in "Email", with: "niran@example.com"
    fill_in "Password", with: "secret123"
    fill_in "Confirm password", with: "secret123"
    click_button "Sign up"
    assert_text "Welcome, Niran!"

    click_on "Sell an item"
    assert_current_path new_product_path
    fill_in "Title", with: "Mechanical keyboard"
    fill_in "Description", with: "Hot-swappable switches, barely used."
    select "Electronics", from: "Category"
    select "Like new", from: "Condition"
    click_button "Next"

    attach_file "Photos", file_fixture("photo.png")
    assert_selector ".image-grid-preview img"
    click_button "Next"

    fill_in "Starting price (฿)", with: "1200"
    click_button "Review"

    assert_text "Mechanical keyboard"
    assert_selector ".status", text: "Draft"
    click_on "Publish"
    assert_text "Your product is now live."

    click_on "View public page"
    assert_selector "h1", text: "Mechanical keyboard"
    assert_selector ".price", text: "1,200"
    assert_selector ".seller-box", text: "Niran"

    visit root_path
    assert_selector ".product-card", text: "Mechanical keyboard"
  end

  test "seller saves a draft and finishes it later from the dashboard" do
    sign_in_with users(:one)

    visit new_product_path
    assert_selector "h1", text: "Sell an item"
    fill_in "Title", with: "Road bike"
    fill_in "Description", with: "Carbon frame."
    select "Fashion", from: "Category"
    click_button "Next"
    assert_selector ".wizard-step-current", text: "Images"
    click_button "Save draft"

    assert_text "Draft saved"
    within ".seller-products" do
      assert_text "Road bike"
      assert_text "No price yet"
    end

    visit root_path
    assert_no_text "Road bike"
  end
end
