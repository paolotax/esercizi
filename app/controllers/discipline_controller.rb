class DisciplineController < ApplicationController
  allow_any_account_scope

  def show
    @disciplina = Disciplina.find(params[:id])
    @pagine = @disciplina.pagine
  end
end
