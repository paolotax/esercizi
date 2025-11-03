class PagineController < ApplicationController
  def show
    @pagina = Pagina.find_by!(slug: params[:slug])

    # Set the page title for the header with full path: Corso - Volume - Disciplina
    parts = []
    parts << @pagina.corso.nome if @pagina.corso
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
