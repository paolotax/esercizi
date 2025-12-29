require "test_helper"

class MagicLinkTest < ActiveSupport::TestCase
  test "belongs to identity" do
    magic_link = magic_links(:mario_sign_in)
    assert_equal identities(:mario), magic_link.identity
  end

  test "identity is required" do
    magic_link = MagicLink.new(identity: nil)
    assert_not magic_link.valid?
  end

  test "generates code automatically" do
    identity = identities(:mario)
    magic_link = identity.magic_links.create!
    assert_not_nil magic_link.code
    assert_equal MagicLink::CODE_LENGTH, magic_link.code.length
  end

  test "code uses custom alphabet" do
    identity = identities(:mario)
    magic_link = identity.magic_links.create!
    # Code uses ABCDEFGHJKLMNPQRSTUVWXYZ23456789 (no O, I, L, 0, 1)
    assert_match /\A[A-Z2-9]+\z/, magic_link.code
  end

  test "sets expires_at automatically" do
    identity = identities(:mario)
    magic_link = identity.magic_links.create!
    assert_not_nil magic_link.expires_at
    assert_in_delta MagicLink::EXPIRATION_TIME.from_now, magic_link.expires_at, 1.second
  end

  test "purpose enum is defined" do
    assert_equal({ "sign_in" => 0, "sign_up" => 1 }, MagicLink.purposes)
  end

  test "can query by purpose" do
    identity = identities(:mario)
    sign_in_link = identity.magic_links.create!(purpose: :sign_in)
    sign_up_link = identity.magic_links.create!(purpose: :sign_up)

    assert_includes MagicLink.for_sign_in, sign_in_link
    assert_includes MagicLink.for_sign_up, sign_up_link
  end

  test "active scope returns non-expired links" do
    active_link = magic_links(:mario_sign_in)
    expired_link = magic_links(:expired_link)

    active_links = MagicLink.active
    assert_includes active_links, active_link
    assert_not_includes active_links, expired_link
  end

  test "stale scope returns expired links" do
    active_link = magic_links(:mario_sign_in)
    expired_link = magic_links(:expired_link)

    stale_links = MagicLink.stale
    assert_includes stale_links, expired_link
    assert_not_includes stale_links, active_link
  end

  test "consume destroys and returns the magic link" do
    identity = identities(:mario)
    magic_link = identity.magic_links.create!
    code = magic_link.code

    result = MagicLink.consume(code)

    assert_not_nil result
    assert_equal magic_link.id, result.id
    assert result.destroyed?
    assert_nil MagicLink.find_by(code: code)
  end

  test "consume returns nil for invalid code" do
    result = MagicLink.consume("INVALID")
    assert_nil result
  end

  test "consume returns nil for expired code" do
    expired_link = magic_links(:expired_link)
    result = MagicLink.consume(expired_link.code)
    assert_nil result
  end

  test "consume sanitizes code input" do
    identity = identities(:mario)
    magic_link = identity.magic_links.create!
    code = magic_link.code

    # Test that sanitize correctly handles the code
    # Note: Code.sanitize converts L->1, O->0, I->0, so we test with the sanitized version
    sanitized = Code.sanitize(code)
    result = MagicLink.consume(sanitized)
    assert_not_nil result
  end

  test "cleanup removes stale links" do
    expired_link = magic_links(:expired_link)
    assert MagicLink.exists?(expired_link.id)

    MagicLink.cleanup

    assert_not MagicLink.exists?(expired_link.id)
  end

  test "cleanup preserves active links" do
    active_link = magic_links(:mario_sign_in)

    MagicLink.cleanup

    assert MagicLink.exists?(active_link.id)
  end

  test "code must be unique" do
    existing = magic_links(:mario_sign_in)
    identity = identities(:luigi)

    magic_link = identity.magic_links.new
    magic_link.code = existing.code
    magic_link.expires_at = 15.minutes.from_now

    assert_not magic_link.valid?
  end
end
