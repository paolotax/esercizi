# frozen_string_literal: true

module Admin
  class SharesController < BaseController
    before_action :set_share, only: [ :destroy ]

    def index
      @shares = Share.includes(:shareable, :recipient)
                     .where(shareable_type: %w[Corso Volume Disciplina Pagina])
                     .order(created_at: :desc)
    end

    def new
      @share = Share.new
      @corsi = Corso.all
      @volumi = Volume.includes(:corso).all
      @discipline = Disciplina.includes(volume: :corso).all
      @users = User.includes(:account).active
      @accounts = Account.all
    end

    def create
      @share = Share.new(share_params)
      @share.granted_by = Current.user

      if @share.save
        redirect_to admin_shares_path, notice: "Accesso assegnato"
      else
        @corsi = Corso.all
        @volumi = Volume.includes(:corso).all
        @discipline = Disciplina.includes(volume: :corso).all
        @users = User.includes(:account).active
        @accounts = Account.all
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      @share.destroy
      redirect_to admin_shares_path, notice: "Accesso revocato"
    end

    private

    def set_share
      @share = Share.find(params[:id])
    end

    def share_params
      params.require(:share).permit(
        :shareable_type, :shareable_id,
        :recipient_type, :recipient_id,
        :permission, :expires_at
      )
    end
  end
end
