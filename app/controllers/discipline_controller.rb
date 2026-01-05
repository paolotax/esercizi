class DisciplineController < ApplicationController
  include ResourceAuthorization
  allow_any_account_scope

  def show
    @disciplina = Disciplina.find(params[:id])
    authorize_resource!(@disciplina)
    @pagine = if admin?
      @disciplina.pagine
    else
      @disciplina.pagine.accessible_by(current_user_or_guest)
    end
  end
end
