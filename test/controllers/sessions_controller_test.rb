require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  test "should get new" do
    get new_session_url
    assert_response :success
    assert_select "form"
  end

  test "create with existing identity sends magic link" do
    identity = identities(:mario)

    assert_enqueued_emails 1 do
      assert_difference "MagicLink.count", 1 do
        post session_url, params: { email_address: identity.email_address }
      end
    end

    assert_redirected_to session_magic_link_url
  end

  test "create with existing identity sets pending authentication token" do
    identity = identities(:mario)

    post session_url, params: { email_address: identity.email_address }

    assert cookies[:pending_authentication_token].present?
  end

  test "create with new email creates identity when signups allowed" do
    # Account.accepting_signups? returns true by default
    new_email = "newuser_#{SecureRandom.hex(4)}@example.com"

    assert_difference "Identity.count", 1 do
      post session_url, params: { email_address: new_email }
    end

    assert_redirected_to session_magic_link_url
    assert Identity.exists?(email_address: new_email)
  end

  test "create normalizes email address" do
    new_email = "UPPERCASE_#{SecureRandom.hex(4)}@EXAMPLE.COM"

    post session_url, params: { email_address: new_email }

    normalized_email = new_email.downcase
    assert Identity.exists?(email_address: normalized_email)
  end

  test "destroy redirects to login" do
    delete session_url
    assert_redirected_to new_session_url
  end
end
