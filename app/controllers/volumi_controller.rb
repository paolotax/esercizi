class VolumiController < ApplicationController
  allow_any_account_scope

  def index
    @volumi = Volume.all.includes(:corso, discipline: :pagine)
  end

  def show
    @volume = Volume.find(params[:id])
    @discipline = @volume.discipline.includes(:pagine)
  end
end
