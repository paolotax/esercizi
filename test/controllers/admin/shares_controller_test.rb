require "test_helper"

class Admin::SharesControllerTest < ActionDispatch::IntegrationTest
  # Note: Integration tests for authenticated routes are complex due to
  # cookie signing. The admin access control is based on User::Admin concern
  # which is tested in test/models/user/admin_test.rb
  #
  # These tests verify basic routing and unauthenticated access behavior.

  setup do
    @account = accounts(:scuola_test)
    @account_slug = AccountSlug.encode(@account.external_account_id)
  end

  def admin_shares_url_with_account
    "/#{@account_slug}/admin/shares"
  end

  test "unauthenticated user is redirected from admin shares" do
    get admin_shares_url_with_account
    assert_response :redirect
  end

  test "admin shares route exists" do
    get admin_shares_url_with_account
    assert_not_equal 404, response.status
  end
end
