# frozen_string_literal: true

module ResourceAuthorization
  extend ActiveSupport::Concern

  private

  def authorize_resource!(resource)
    unless resource_accessible?(resource)
      redirect_to root_path, alert: "Non hai accesso a questa risorsa"
    end
  end

  def resource_accessible?(resource)
    return true if admin?
    return true if resource.respond_to?(:public?) && resource.public?
    return false unless Current.user

    resource.accessible_by?(Current.user)
  end

  def current_user_or_guest
    Current.user || Guest.new
  end

  def admin?
    return false unless Current.identity

    admin_emails = Rails.application.credentials.admin_emails || []
    admin_emails.include?(Current.identity.email_address)
  end
end
