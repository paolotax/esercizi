ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module AuthenticationTestHelper
  # Simula login impostando il cookie di sessione (per integration tests)
  def sign_in_as(session)
    # Integration tests need signed cookies
    cookies.signed[:session_token] = session.signed_id
  end

  # Imposta Current per i test (per unit tests)
  def set_current(account:, user:)
    Current.account = account
    Current.user = user
  end
end

class ActionDispatch::IntegrationTest
  include AuthenticationTestHelper
end
