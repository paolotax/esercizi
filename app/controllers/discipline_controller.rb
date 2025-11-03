class DisciplineController < ApplicationController
  def show
    @disciplina = Disciplina.find(params[:id])
    @pagine = @disciplina.pagine
  end
end
