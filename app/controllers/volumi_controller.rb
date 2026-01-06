class VolumiController < ApplicationController
  include ResourceAuthorization
  allow_any_account_scope

  def index
    # Se autenticato ma senza account selezionato, redirect a selezione account
    if Current.identity.present? && Current.account.blank?
      return redirect_to session_menu_path(script_name: nil)
    end

    @volumi = if admin?
      Volume.all.includes(:corso, discipline: :pagine)
    elsif Current.user
      Volume.accessible_by(Current.user).includes(:corso, discipline: :pagine)
    else
      Volume.with_public_pages.includes(:corso, discipline: :pagine)
    end
  end

  def show
    @volume = Volume.find(params[:id])
    authorize_resource!(@volume)
    @discipline = if admin?
      @volume.discipline.includes(:pagine)
    else
      @volume.discipline.accessible_by(current_user_or_guest).includes(:pagine)
    end
  end
end
