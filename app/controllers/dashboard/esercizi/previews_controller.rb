# frozen_string_literal: true

class Dashboard::Esercizi::PreviewsController < ApplicationController
  require_teacher
  before_action :set_esercizio

  # GET /dashboard/esercizi/:esercizio_id/preview
  def show
    render layout: "preview"
  end

  private

  def set_esercizio
    @esercizio = Esercizio.find(params[:esercizio_id])
  end
end
