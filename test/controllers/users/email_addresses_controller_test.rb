require "test_helper"

class Users::EmailAddressesControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup do
    @user = users(:mario_teacher)
    sign_in_as :mario
  end

  test "new" do
    get new_user_email_address_path(@user, script_name: @user.account.slug)
    assert_response :success
  end

  test "create sends confirmation email" do
    assert_emails 1 do
      post user_email_addresses_path(@user, script_name: @user.account.slug), params: { email_address: "newemail@example.com" }
    end
    assert_response :success
  end

  test "create with existing email in same account" do
    existing_user = users(:luigi_student)
    existing_email = existing_user.identity.email_address

    post user_email_addresses_path(@user, script_name: @user.account.slug), params: { email_address: existing_email }

    assert_response :redirect
    assert_equal "Hai già un utente in questo account con quell'indirizzo email", flash[:alert]
  end

  test "create for other user is not authorized" do
    other_user = users(:luigi_student)

    assert_no_emails do
      post user_email_addresses_path(other_user, script_name: @user.account.slug), params: { email_address: "newemail@example.com" }
    end

    assert_response :not_found
  end
end
