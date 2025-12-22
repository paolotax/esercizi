class Sessions::MagicLinksController < ApplicationController
  disallow_account_scope
  allow_unauthenticated_access

  layout "public"

  def show
  end

  def update
    if magic_link = MagicLink.consume(params[:code])
      start_new_session_for(magic_link.identity)

      if magic_link.for_sign_up?
        redirect_to new_signup_path(script_name: nil)
      else
        redirect_to after_authentication_url
      end
    else
      flash.now[:alert] = "Codice non valido o scaduto"
      render :show, status: :unprocessable_entity
    end
  end
end
