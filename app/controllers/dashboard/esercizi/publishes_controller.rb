# frozen_string_literal: true

class Dashboard::Esercizi::PublishesController < ApplicationController
  require_teacher
  before_action :set_esercizio

  # POST /dashboard/esercizi/:esercizio_id/publish
  def create
    @esercizio.publish!

    respond_to do |format|
      format.html { redirect_to dashboard_esercizio_path(@esercizio), notice: "Esercizio pubblicato." }
      format.turbo_stream
    end
  end

  # DELETE /dashboard/esercizi/:esercizio_id/publish
  def destroy
    @esercizio.unpublish!

    respond_to do |format|
      format.html { redirect_to dashboard_esercizio_path(@esercizio), notice: "Esercizio ritirato." }
      format.turbo_stream
    end
  end

  private

  def set_esercizio
    @esercizio = Esercizio.find(params[:esercizio_id])
  end
end
