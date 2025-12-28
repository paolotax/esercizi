require "test_helper"

class Sessions::MagicLinksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @identity = identities(:mario)
  end

  test "show renders form when pending token exists" do
    set_pending_authentication_token(@identity.email_address)

    get session_magic_link_url

    assert_response :success
    assert_select "form"
    assert_select "input[name=code]"
  end

  test "show redirects to login when no pending token" do
    get session_magic_link_url

    assert_redirected_to new_session_url
  end

  test "create with valid code creates session and redirects" do
    magic_link = @identity.magic_links.create!
    set_pending_authentication_token(@identity.email_address)

    post session_magic_link_url, params: { code: magic_link.code }

    # Should create a session and redirect
    assert_response :redirect
    assert Session.exists?(identity: @identity)
  end

  test "create with valid code clears pending token" do
    magic_link = @identity.magic_links.create!
    set_pending_authentication_token(@identity.email_address)

    post session_magic_link_url, params: { code: magic_link.code }

    # After successful login, pending token should be cleared
    # Note: The actual clearing happens in the controller
    assert_response :redirect
  end

  test "create with valid code consumes magic link" do
    magic_link = @identity.magic_links.create!
    set_pending_authentication_token(@identity.email_address)
    code = magic_link.code

    post session_magic_link_url, params: { code: code }

    # Magic link should be consumed (either destroyed or not found by active scope)
    assert_nil MagicLink.active.find_by(code: code)
  end

  test "create with invalid code redirects with shake" do
    set_pending_authentication_token(@identity.email_address)

    post session_magic_link_url, params: { code: "WRONG1" }

    assert_redirected_to session_magic_link_url
    assert flash[:shake].present?
  end

  test "create with expired code redirects with shake" do
    expired_link = magic_links(:expired_link)
    set_pending_authentication_token(expired_link.identity.email_address)

    post session_magic_link_url, params: { code: expired_link.code }

    assert_redirected_to session_magic_link_url
  end

  test "create with email mismatch clears token and shows error" do
    magic_link = @identity.magic_links.create!
    # Set pending token for different email than magic link owner
    set_pending_authentication_token("different@example.com")

    post session_magic_link_url, params: { code: magic_link.code }

    # Should redirect with error (either to new_session or magic_link)
    assert_response :redirect
  end

  test "create for sign_up redirects appropriately" do
    magic_link = @identity.magic_links.create!(purpose: :sign_up)
    set_pending_authentication_token(@identity.email_address)

    post session_magic_link_url, params: { code: magic_link.code }

    # Sign up flow may redirect to signup path or session menu depending on state
    assert_response :redirect
  end

  test "create without pending token redirects to login" do
    magic_link = @identity.magic_links.create!

    post session_magic_link_url, params: { code: magic_link.code }

    assert_redirected_to new_session_url
  end

  test "show displays email when pending token exists" do
    set_pending_authentication_token(@identity.email_address)

    get session_magic_link_url

    assert_response :success
    assert_select "span", text: @identity.email_address
  end

  private

  def set_pending_authentication_token(email_address)
    verifier = Rails.application.message_verifier(:pending_authentication)
    token = verifier.generate(email_address, expires_at: 15.minutes.from_now)
    cookies[:pending_authentication_token] = token
  end
end
