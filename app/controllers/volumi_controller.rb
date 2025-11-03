class VolumiController < ApplicationController
  def index
    @volumi = Volume.all.includes(:corso, discipline: :pagine)
  end

  def show
    @volume = Volume.find(params[:id])
    @discipline = @volume.discipline.includes(:pagine)
  end
end
