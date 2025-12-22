class PagineController < ApplicationController
  allow_any_account_scope

  def show
    @pagina = Pagina.find_by!(slug: params[:slug])

    # Set the page title for the header: Volume - Disciplina
    parts = []
    parts << @pagina.volume.nome if @pagina.volume
    parts << @pagina.disciplina.nome if @pagina.disciplina
    @page_title = parts.join(" - ")

    # Render the specific view template for this page if it exists
    if @pagina.view_template.present? && template_exists?("exercises/#{@pagina.view_template}")
      render "exercises/#{@pagina.view_template}"
    else
      # Fallback to default page view
      render :show
    end
  end
end
