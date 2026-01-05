class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Authentication
  include Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  # Layout dinamico per Turbo Frames
  layout -> { turbo_frame_request? ? "turbo_frame" : "application" }

  # Helper per rilevare richieste Turbo Frame
  helper_method :turbo_frame_request?

  def turbo_frame_request?
    request.headers["Turbo-Frame"].present?
  end

  # Helper per verificare se l'utente è admin
  helper_method :admin?

  def admin?
    return false unless Current.identity

    admin_emails = Rails.application.credentials.admin_emails || []
    admin_emails.include?(Current.identity.email_address)
  end
end
