# frozen_string_literal: true

class Account::SharesController < ApplicationController
  before_action :require_owner

  def index
    # Share all'account (dall'admin) + share a utenti dell'account (dall'owner)
    account_shares = Share.where(recipient_type: "Account", recipient_id: Current.account.id)
    user_shares = Share.where(recipient_type: "User", recipient_id: Current.account.users.select(:id))

    @shares = Share.where(id: account_shares.select(:id))
                   .or(Share.where(id: user_shares.select(:id)))
                   .includes(:shareable, :recipient, :granted_by)
                   .order(created_at: :desc)
  end

  def new
    @share = Share.new
    @available_resources = available_resources
    @users = Current.account.users.active.where.not(id: Current.user.id)
  end

  def create
    @share = Share.new(share_params)
    @share.granted_by = Current.user
    @share.permission = :view

    unless resource_accessible_to_account?(@share.shareable)
      return redirect_to account_shares_path, alert: "Non puoi condividere questa risorsa"
    end

    unless valid_recipient?(@share.recipient)
      return redirect_to account_shares_path, alert: "Destinatario non valido"
    end

    if @share.save
      redirect_to account_shares_path, notice: "Accesso assegnato"
    else
      @available_resources = available_resources
      @users = Current.account.users.active.where.not(id: Current.user.id)
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @share = Share.find(params[:id])

    unless @share.granted_by == Current.user
      return redirect_to account_shares_path, alert: "Non puoi rimuovere questa condivisione"
    end

    @share.destroy
    redirect_to account_shares_path, notice: "Accesso revocato"
  end

  private

  def require_owner
    redirect_to root_path, alert: "Accesso riservato" unless Current.user&.owner?
  end

  def share_params
    params.require(:share).permit(
      :shareable_type, :shareable_id,
      :recipient_id
    ).merge(recipient_type: "User")
  end

  def available_resources
    {
      corsi: Corso.accessible_by(Current.user),
      volumi: Volume.accessible_by(Current.user),
      discipline: Disciplina.accessible_by(Current.user),
      pagine: Pagina.accessible_by(Current.user)
    }
  end

  def resource_accessible_to_account?(resource)
    return false unless resource

    resource.accessible_by?(Current.user)
  end

  def valid_recipient?(recipient)
    return false unless recipient.is_a?(User)

    recipient.account == Current.account && recipient != Current.user
  end
end
