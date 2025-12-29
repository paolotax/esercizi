require "test_helper"

class PagineControllerTest < ActionDispatch::IntegrationTest
  # Note: Integration tests for authenticated routes are complex due to
  # cookie signing. The access control logic is thoroughly tested in
  # test/models/concerns/accessible_test.rb
  #
  # These tests verify basic routing and unauthenticated access behavior.

  setup do
    @pagina = pagine(:pagina_uno)
    @account = accounts(:scuola_test)
    @account_slug = AccountSlug.encode(@account.external_account_id)
  end

  def pagina_url_with_account(slug)
    "/#{@account_slug}/pagine/#{slug}"
  end

  test "unauthenticated user is redirected to login" do
    get pagina_url_with_account(@pagina.slug)
    assert_response :redirect
  end

  test "pagina route responds to GET" do
    # Just verify the route exists - authentication will redirect
    get pagina_url_with_account(@pagina.slug)
    assert_not_equal 404, response.status
  end
end
