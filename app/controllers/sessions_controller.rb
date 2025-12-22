class SessionsController < ApplicationController
  disallow_account_scope
  require_unauthenticated_access except: :destroy
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Troppi tentativi. Riprova tra qualche minuto." }

  layout "public"

  def new
  end

  def create
    if identity = Identity.find_by(email_address: email_address)
      redirect_to_session_magic_link identity.send_magic_link
    elsif Account.accepting_signups?
      identity = Identity.create!(email_address: email_address)
      redirect_to_session_magic_link identity.send_magic_link(for: :sign_up)
    else
      flash.now[:alert] = "Email non registrata"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path(script_name: nil)
  end

  private
    def email_address
      params.require(:email_address)
    end
end
