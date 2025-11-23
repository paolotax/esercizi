class Dashboard::EserciziController < ApplicationController
  before_action :set_esercizio, only: [:show, :edit, :update, :destroy, :duplicate, :preview, :export_pdf]

  def index
    @esercizi = Esercizio.includes(:esercizio_attempts)
    @esercizi = @esercizi.by_category(params[:category]) if params[:category].present?
    @esercizi = @esercizi.by_difficulty(params[:difficulty]) if params[:difficulty].present?
    @esercizi = @esercizi.with_tag(params[:tag]) if params[:tag].present?

    @esercizi = case params[:status]
                when 'published'
                  @esercizi.published
                when 'draft'
                  @esercizi.draft
                else
                  @esercizi
                end

    @esercizi = @esercizi.order(created_at: :desc)
    @pagy, @esercizi = pagy(@esercizi, items: 12)
  end

  def new
    @esercizio = Esercizio.new
    @templates = EsercizioTemplate.all.order(:category, :name)
  end

  def create
    @esercizio = Esercizio.new(esercizio_params)

    if @esercizio.save
      redirect_to edit_dashboard_esercizio_path(@esercizio),
                  notice: 'Esercizio creato con successo. Ora puoi aggiungere le operazioni.'
    else
      @templates = EsercizioTemplate.all.order(:category, :name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @templates = EsercizioTemplate.all.order(:category, :name)
  end

  def update
    if @esercizio.update(esercizio_params)
      respond_to do |format|
        format.html { redirect_to dashboard_esercizio_path(@esercizio), notice: 'Esercizio aggiornato con successo.' }
        format.json { render json: @esercizio }
      end
    else
      respond_to do |format|
        format.html {
          @templates = EsercizioTemplate.all.order(:category, :name)
          render :edit, status: :unprocessable_entity
        }
        format.json { render json: @esercizio.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @attempts = @esercizio.esercizio_attempts.recent.limit(10)
  end

  def destroy
    @esercizio.destroy
    redirect_to dashboard_esercizi_path, notice: 'Esercizio eliminato con successo.'
  end

  # Azioni custom
  def duplicate
    new_esercizio = @esercizio.dup
    new_esercizio.title = "#{@esercizio.title} (copia)"
    new_esercizio.slug = nil # verrà rigenerato
    new_esercizio.share_token = nil # verrà rigenerato
    new_esercizio.published_at = nil # inizia come bozza
    new_esercizio.views_count = 0

    if new_esercizio.save
      redirect_to edit_dashboard_esercizio_path(new_esercizio),
                  notice: 'Esercizio duplicato con successo.'
    else
      redirect_to dashboard_esercizi_path,
                  alert: 'Errore durante la duplicazione dell\'esercizio.'
    end
  end

  def preview
    render layout: 'preview'
  end

  def export_pdf
    # TODO: Implementare generazione PDF
    redirect_to dashboard_esercizio_path(@esercizio),
                alert: 'Funzionalità PDF in fase di sviluppo.'
  end

  # Endpoint AJAX per il builder
  def add_operation
    @esercizio = Esercizio.find(params[:id])

    # Il metodo add_operation ora salva automaticamente
    if @esercizio.add_operation(params[:operation_type], params[:config] || {})
      # Renderizza HTML per le operazioni invece di JSON
      html = render_to_string(
        partial: 'dashboard/esercizi/operations_list',
        locals: { esercizio: @esercizio }
      )
      render json: { success: true, operations: @esercizio.operations, html: html }
    else
      render json: { success: false, errors: @esercizio.errors.full_messages }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Error adding operation: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { success: false, error: e.message }, status: :internal_server_error
  end

  def remove_operation
    @esercizio = Esercizio.find(params[:id])
    @esercizio.remove_operation(params[:operation_id])

    if @esercizio.save
      render json: { success: true, operations: @esercizio.operations }
    else
      render json: { success: false, errors: @esercizio.errors }
    end
  end

  def reorder_operations
    @esercizio = Esercizio.find(params[:id])

    # Riordina le operazioni secondo l'ordine ricevuto
    if params[:operation_ids].present?
      operations = @esercizio.operations
      reordered = params[:operation_ids].map.with_index do |id, index|
        op = operations.find { |o| o['id'] == id }
        op['position'] = index if op
        op
      end.compact

      @esercizio.content['operations'] = reordered

      if @esercizio.save
        render json: { success: true, operations: @esercizio.operations }
      else
        render json: { success: false, errors: @esercizio.errors }
      end
    else
      render json: { success: false, error: 'No operation IDs provided' }
    end
  end

  private

  def set_esercizio
    @esercizio = Esercizio.find(params[:id])
  end

  def esercizio_params
    params.require(:esercizio).permit(
      :title, :description, :category, :difficulty,
      :published_at, :content, tags: []
    )
  end
end
