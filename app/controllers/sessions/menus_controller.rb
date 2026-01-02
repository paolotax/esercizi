class Sessions::MenusController < ApplicationController
  disallow_account_scope
  # allow_unauthenticated_access

  layout "public"

  def show
    @accounts = Current.identity.accounts.order(:name)

    if @accounts.one?
      redirect_to root_url(script_name: @accounts.first.slug)
    end
  end
end
