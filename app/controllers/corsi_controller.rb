class CorsiController < ApplicationController
  allow_any_account_scope

  def index
    @corsi = Corso.all.includes(:volumi)
  end

  def show
    @corso = Corso.find(params[:id])
    @volumi = @corso.volumi.includes(:discipline)
  end
end
