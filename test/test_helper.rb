ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize workers: :number_of_processors

    fixtures :all

    include ActiveJob::TestHelper

    setup do
      Current.account = accounts(:scuola_test)
    end

    teardown do
      Current.reset
    end
  end
end

module SessionTestHelper
  def parsed_cookies
    ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
  end

  def sign_in_as(identity)
    # Reset integration session state completely and restore script_name
    reset!
    integration_session.default_url_options[:script_name] = "/#{ActiveRecord::FixtureSet.identify(:scuola_test)}"

    if identity.is_a?(User)
      user = identity
      identity = user.identity
      raise "User #{user.name} (#{user.id}) doesn't have an associated identity" unless identity
    elsif !identity.is_a?(Identity)
      identity = identities(identity)
    end

    # Clean up stale magic links to avoid test interference
    identity.magic_links.delete_all

    identity.send_magic_link
    magic_link = identity.magic_links.order(id: :desc).first

    untenanted do
      post session_path, params: { email_address: identity.email_address }
      post session_magic_link_url, params: { code: magic_link.code }
    end

    assert_response :redirect, "Posting the Magic Link code should grant access"

    cookie = cookies.get_cookie "session_token"
    assert_not_nil cookie, "Expected session_token cookie to be set after sign in"
  end

  def logout_and_sign_in_as(identity)
    Session.delete_all
    sign_in_as identity
  end

  def sign_out
    untenanted do
      delete session_path
    end
    assert_not cookies[:session_token].present?
  end

  def untenanted(&block)
    original_script_name = integration_session.default_url_options[:script_name]
    integration_session.default_url_options[:script_name] = ""
    yield
  ensure
    integration_session.default_url_options[:script_name] = original_script_name
  end
end

class ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup do
    integration_session.default_url_options[:script_name] = "/#{ActiveRecord::FixtureSet.identify(:scuola_test)}"
  end
end
