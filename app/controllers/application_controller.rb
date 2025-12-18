class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  # Layout dinamico per Turbo Frames
  layout -> { turbo_frame_request? ? "turbo_frame" : "application" }

  # Helper per rilevare richieste Turbo Frame
  helper_method :turbo_frame_request?

  def turbo_frame_request?
    request.headers["Turbo-Frame"].present?
  end
end
