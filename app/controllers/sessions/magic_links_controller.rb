class Sessions::MagicLinksController < ApplicationController
  disallow_account_scope
  require_unauthenticated_access
  rate_limit to: 10, within: 15.minutes, only: :create, with: :rate_limit_exceeded
  before_action :ensure_that_email_address_pending_authentication_exists

  layout "public"

  def show
  end

  def create
    if magic_link = MagicLink.consume(params[:code])
      authenticate magic_link
    else
      invalid_code
    end
  end

  private
    def ensure_that_email_address_pending_authentication_exists
      unless email_address_pending_authentication.present?
        redirect_to new_session_path(script_name: nil), alert: "Inserisci la tua email per accedere."
      end
    end

    def authenticate(magic_link)
      if ActiveSupport::SecurityUtils.secure_compare(
        email_address_pending_authentication || "",
        magic_link.identity.email_address
      )
        sign_in magic_link
      else
        email_address_mismatch
      end
    end

    def sign_in(magic_link)
      clear_pending_authentication_token
      start_new_session_for magic_link.identity

      if magic_link.for_sign_up?
        redirect_to new_signup_path(script_name: nil)
      else
        redirect_to after_authentication_url
      end
    end

    def email_address_mismatch
      clear_pending_authentication_token
      redirect_to new_session_path(script_name: nil), alert: "Qualcosa è andato storto. Riprova."
    end

    def invalid_code
      redirect_to session_magic_link_path(script_name: nil), flash: { shake: true }
    end

    def rate_limit_exceeded
      redirect_to session_magic_link_path(script_name: nil), alert: "Riprova tra 15 minuti."
    end
end
