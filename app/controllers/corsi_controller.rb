class CorsiController < ApplicationController
  include ResourceAuthorization
  allow_any_account_scope

  def index
    @corsi = if admin?
      Corso.all.includes(:volumi)
    elsif Current.user
      Corso.accessible_by(Current.user).includes(:volumi)
    else
      Corso.with_public_pages.includes(:volumi)
    end
  end

  def show
    @corso = Corso.find(params[:id])
    authorize_resource!(@corso)
    @volumi = if admin?
      @corso.volumi.includes(:discipline)
    else
      @corso.volumi.accessible_by(current_user_or_guest).includes(:discipline)
    end
  end
end
