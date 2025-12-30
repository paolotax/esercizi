require "test_helper"

class IdentityTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "email address must be present" do
    identity = Identity.new(email_address: nil)
    assert_not identity.valid?
    assert_includes identity.errors[:email_address], "can't be blank"
  end

  test "email address must be unique" do
    existing = identities(:mario)
    identity = Identity.new(email_address: existing.email_address)
    assert_not identity.valid?
    assert_includes identity.errors[:email_address], "has already been taken"
  end

  test "email address must have valid format" do
    invalid_emails = [ "invalid", "@example.com", "test@" ]
    invalid_emails.each do |email|
      identity = Identity.new(email_address: email)
      assert_not identity.valid?, "#{email} should be invalid"
    end
  end

  test "valid email addresses are accepted" do
    valid_emails = [ "test@example.com", "user@domain.org", "name+tag@gmail.com" ]
    valid_emails.each do |email|
      identity = Identity.new(email_address: email)
      identity.valid?
      assert_not identity.errors[:email_address].include?("is invalid"), "#{email} should be valid"
    end
  end

  test "email address is normalized to lowercase" do
    identity = Identity.new(email_address: "MARIO@EXAMPLE.COM")
    assert_equal "mario@example.com", identity.email_address
  end

  test "email address is stripped of whitespace" do
    identity = Identity.new(email_address: "  test@example.com  ")
    assert_equal "test@example.com", identity.email_address
  end

  test "send_magic_link creates a magic link" do
    identity = identities(:mario)
    assert_difference "MagicLink.count", 1 do
      identity.send_magic_link
    end
  end

  test "send_magic_link sends email" do
    identity = identities(:mario)
    assert_enqueued_emails 1 do
      identity.send_magic_link
    end
  end

  test "send_magic_link with for: :sign_up creates sign_up type" do
    identity = identities(:mario)
    magic_link = identity.send_magic_link(for: :sign_up)
    # Verify it's created with sign_up purpose
    assert_includes MagicLink.for_sign_up, magic_link
  end

  test "has many sessions" do
    identity = identities(:mario)
    assert_respond_to identity, :sessions
  end

  test "has many magic_links" do
    identity = identities(:mario)
    assert_respond_to identity, :magic_links
  end
end
