require "test_helper"

class SessionTest < ActiveSupport::TestCase
  test "belongs to identity" do
    session = sessions(:mario_session)
    assert_equal identities(:mario), session.identity
  end

  test "identity is required" do
    session = Session.new(identity: nil)
    assert_not session.valid?
  end

  test "stores ip_address" do
    session = sessions(:mario_session)
    assert_equal "127.0.0.1", session.ip_address
  end

  test "stores user_agent" do
    session = sessions(:mario_session)
    assert_equal "Test Browser", session.user_agent
  end

  test "signed_id returns a token" do
    session = sessions(:mario_session)
    token = session.signed_id
    assert_not_nil token
    assert_kind_of String, token
  end

  test "find_signed returns session from valid token" do
    session = sessions(:mario_session)
    token = session.signed_id
    found = Session.find_signed(token)
    assert_equal session, found
  end

  test "find_signed returns nil for invalid token" do
    found = Session.find_signed("invalid_token")
    assert_nil found
  end

  test "find_signed returns nil for tampered token" do
    session = sessions(:mario_session)
    token = session.signed_id
    tampered = token + "tampered"
    found = Session.find_signed(tampered)
    assert_nil found
  end

  test "find_signed returns nil for nil token" do
    found = Session.find_signed(nil)
    assert_nil found
  end

  test "can create session with identity" do
    identity = identities(:mario)
    session = identity.sessions.create!(
      ip_address: "10.0.0.1",
      user_agent: "New Browser"
    )
    assert session.persisted?
    assert_equal identity, session.identity
  end
end
