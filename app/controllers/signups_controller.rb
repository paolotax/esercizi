class SignupsController < ApplicationController
  disallow_account_scope
  allow_unauthenticated_access only: [ :new, :create ]

  layout "public"

  def new
    redirect_to new_session_path(script_name: nil) unless authenticated?
  end

  def create
    account = Account.create_with_owner(
      account: { name: params[:account_name] },
      owner: { identity: Current.identity, name: params[:user_name] }
    )

    redirect_to root_url(script_name: account.slug)
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    render :new, status: :unprocessable_entity
  end
end
