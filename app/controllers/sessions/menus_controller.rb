class Sessions::MenusController < ApplicationController
  disallow_account_scope
  allow_unauthenticated_access

  layout "public"

  def show
    unless authenticated?
      redirect_to new_session_path(script_name: nil)
      return
    end

    @accounts = Current.identity.accounts.order(:name)

    if @accounts.one?
      redirect_to root_url(script_name: @accounts.first.slug)
    end
  end
end
