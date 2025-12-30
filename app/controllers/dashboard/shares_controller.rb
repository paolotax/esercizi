# frozen_string_literal: true

class Dashboard::SharesController < ApplicationController
  require_teacher

  before_action :set_esercizio
  before_action :set_share, only: [ :destroy ]

  def index
    @shares = @esercizio.shares.includes(:granted_by)
  end

  def create
    @share = @esercizio.shares.build(share_params)
    @share.granted_by = Current.user

    if @share.save
      @esercizio.make_shared! if @esercizio.draft? || @esercizio.private_status?

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_dashboard_esercizio_path(@esercizio), notice: "Condivisione aggiunta." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("share_form", partial: "dashboard/shares/form", locals: { esercizio: @esercizio, share: @share }) }
        format.html { redirect_to edit_dashboard_esercizio_path(@esercizio), alert: @share.errors.full_messages.join(", ") }
      end
    end
  end

  def destroy
    @share.destroy

    @esercizio.make_private! if @esercizio.shared? && @esercizio.shares.empty?

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@share) }
      format.html { redirect_to edit_dashboard_esercizio_path(@esercizio), notice: "Condivisione rimossa." }
    end
  end

  private

  def set_esercizio
    @esercizio = Esercizio.find(params[:esercizio_id])
  end

  def set_share
    @share = @esercizio.shares.find(params[:id])
  end

  def share_params
    params.require(:share).permit(:recipient_type, :recipient_id, :permission, :expires_at)
  end
end
