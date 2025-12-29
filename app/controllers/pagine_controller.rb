class PagineController < ApplicationController
  allow_any_account_scope
  before_action :set_pagina
  before_action :authorize_pagina!

  def show

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

  private

  def set_pagina
    @pagina = Pagina.find_by!(slug: params[:slug])
  end

  def authorize_pagina!
    unless pagina_accessible?
      redirect_to root_path, alert: "Non hai accesso a questa pagina"
    end
  end

  def pagina_accessible?
    # Admin check via identity (works without account scope)
    if Current.identity && admin_identity?
      return true
    end

    # Regular user check (requires account scope for Current.user)
    Current.user && @pagina.accessible_by?(Current.user)
  end

  def admin_identity?
    admin_emails = Rails.application.credentials.admin_emails || []
    admin_emails.include?(Current.identity.email_address)
  end
end
