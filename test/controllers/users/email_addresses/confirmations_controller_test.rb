require "test_helper"

class Users::EmailAddresses::ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Use dedicated user to avoid conflicts with other controller tests
    @user = users(:confirmations_test_user)
    @old_email = @user.identity.email_address
    @new_email = "newemail@example.com"
    @token = @user.send(:generate_email_address_change_token, to: @new_email)
  end

  test "show renders confirmation page" do
    get user_email_address_confirmation_path(user_id: @user.id, email_address_token: @token, script_name: @user.account.slug)
    assert_response :success
    assert_match /Conferma cambio email/, response.body
  end

  test "create changes email and redirects" do
    post user_email_address_confirmation_path(user_id: @user.id, email_address_token: @token, script_name: @user.account.slug)

    assert_equal @new_email, @user.reload.identity.email_address
    assert_redirected_to edit_user_url(script_name: @user.account.slug, id: @user)
  end

  test "create with invalid token shows error" do
    post user_email_address_confirmation_path(user_id: @user.id, email_address_token: "invalid", script_name: @user.account.slug)

    assert_equal @old_email, @user.reload.identity.email_address
    assert_response :unprocessable_entity
    assert_match /Link scaduto/, response.body
  end

  test "create creates new session" do
    post user_email_address_confirmation_path(user_id: @user.id, email_address_token: @token, script_name: @user.account.slug)

    assert cookies[:session_token].present?
  end
end
