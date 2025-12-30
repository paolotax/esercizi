# frozen_string_literal: true

module User::Admin
  extend ActiveSupport::Concern

  def admin?
    return false unless identity

    self.class.admin_emails.include?(identity.email_address)
  end

  class_methods do
    def admin_emails
      # In test environment, include test admin email
      emails = Rails.application.credentials.admin_emails || []
      emails += [ "admin@example.com" ] if Rails.env.test?
      emails
    end
  end
end
