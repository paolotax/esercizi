# frozen_string_literal: true

require "test_helper"

class User::AdminTest < ActiveSupport::TestCase
  test "admin? returns true for user with admin email" do
    admin = users(:admin_user)

    # Verify the identity has the test admin email
    assert_equal "admin@example.com", admin.identity.email_address

    # In test environment, admin@example.com is automatically added
    assert_includes User.admin_emails, "admin@example.com"

    assert admin.admin?
  end

  test "admin? returns false for regular user" do
    mario = users(:mario_teacher)

    assert_equal "mario@example.com", mario.identity.email_address
    assert_not mario.admin?
  end

  test "admin? returns false for user without identity" do
    user = User.new(name: "Test", role: :student)
    user.account = accounts(:scuola_test)

    assert_not user.admin?
  end

  test "admin? returns false for email not in admin list" do
    mario = users(:mario_teacher)

    # mario@example.com is not in admin_emails list
    assert_not mario.admin?
  end
end
