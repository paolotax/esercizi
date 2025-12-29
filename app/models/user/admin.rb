# frozen_string_literal: true

module User::Admin
  extend ActiveSupport::Concern

  def admin?
    return false unless identity

    admin_emails = Rails.application.credentials.admin_emails || []
    admin_emails.include?(identity.email_address)
  end
end
