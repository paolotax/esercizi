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

  # Mostra le proprietà di un'operazione
  def operation_properties
    @esercizio = Esercizio.find(params[:id])
    operation_id = params[:operation_id]
    operation = @esercizio.operations.find { |op| op['id'] == operation_id }

    if operation
      respond_to do |format|
        format.html {
          render partial: "dashboard/esercizi/#{operation['type']}_form",
                 locals: { operation: operation, esercizio: @esercizio }
        }
        format.turbo_stream
      end
    else
      render plain: "Operazione non trovata", status: :not_found
    end
  end

  # Aggiorna un'operazione specifica
  def update_operation
    @esercizio = Esercizio.find(params[:id])
    operation_id = params[:operation_id]

    operations = @esercizio.operations
    operation_index = operations.find_index { |op| op['id'] == operation_id }

    if operation_index
      # Permetti tutti i parametri config e convertili in hash
      config_params = params[:config].permit! if params[:config]
      config = config_params ? config_params.to_h : {}

      # Gestisci i checkbox - se non sono presenti nei parametri, sono false
      boolean_fields = ['show_toolbar', 'show_carry', 'show_addends', 'show_solution',
                       'show_borrow', 'allow_borrow', 'allow_negative',
                       'show_partial_products', 'show_grid',
                       'show_thousands', 'show_hundreds', 'show_value', 'editable', 'disable_auto_zeros']

      boolean_fields.each do |field|
        # Se il campo esiste nei parametri, è true (perché i checkbox inviano solo se checked)
        # Se non esiste, è false
        config[field] = config.key?(field) ? true : false
      end

      # Controlla se ci sono operazioni multiple nella textarea
      if config['operation_text'].present?
        operation_type = operations[operation_index]['type']
        multiple_operations = parse_multiple_operations(config['operation_text'], operation_type)

        if multiple_operations && multiple_operations.size > 1
          # Rimuovi l'operazione corrente
          operations.delete_at(operation_index)

          # Aggiungi le nuove operazioni multiple
          multiple_operations.each do |op_text|
            new_config = config.dup
            new_config['operation_text'] = op_text.strip
            parsed_values = parse_operation_text(op_text.strip, operation_type)
            new_config['values'] = parsed_values['values'] if parsed_values && parsed_values['values']
            # Mantieni il titolo se presente
            new_config['title'] = config['title'] if config['title'].present?

            new_operation = {
              'id' => SecureRandom.uuid,
              'type' => operation_type,
              'config' => new_config,
              'position' => operations.size
            }
            operations << new_operation
          end

          @esercizio.content['operations'] = operations
          @esercizio.content_will_change!

          if @esercizio.save
            redirect_to edit_dashboard_esercizio_path(@esercizio),
                        notice: "Create #{multiple_operations.size} operazioni dall'input."
            return
          end
        else
          # Operazione singola - comportamento normale
          parsed_values = parse_operation_text(config['operation_text'], operation_type)
          config.merge!(parsed_values) if parsed_values
        end
      end

      # Mantieni la config esistente e aggiorna con i nuovi valori
      existing_config = operations[operation_index]['config'] || {}
      operations[operation_index]['config'] = existing_config.merge(config)
      @esercizio.content['operations'] = operations
      @esercizio.content_will_change!

      if @esercizio.save
        redirect_to edit_dashboard_esercizio_path(@esercizio),
                    notice: 'Operazione aggiornata con successo.'
      else
        redirect_to edit_dashboard_esercizio_path(@esercizio),
                    alert: 'Errore nell\'aggiornamento dell\'operazione.'
      end
    else
      redirect_to edit_dashboard_esercizio_path(@esercizio),
                  alert: 'Operazione non trovata.'
    end
  end

  # Endpoint AJAX per il builder
  def add_operation
    @esercizio = Esercizio.find(params[:id])

    # Il metodo add_operation ora salva automaticamente con posizione opzionale
    position = params[:position].present? ? params[:position].to_i : nil
    if @esercizio.add_operation(params[:operation_type], params[:config] || {}, position)
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

  def parse_multiple_operations(text, type)
    # Prima dividi per newline e punto e virgola
    operations = text.split(/[\n\r;]/)
                    .map(&:strip)
                    .reject(&:empty?)

    # Poi controlla se ci sono virgole che potrebbero essere separatori
    # (solo se non ci sono già operazioni multiple e non ci sono operatori)
    if operations.size == 1 && !operations[0].include?('+') && !operations[0].include?('-') && !operations[0].include?('×') && !operations[0].include?('x')
      # Prova a dividere per virgola
      operations = operations[0].split(',')
                                .map(&:strip)
                                .reject(&:empty?)
    end

    # Se c'è solo un'operazione, ritorna nil per usare il comportamento normale
    return nil if operations.size <= 1

    # Ritorna l'array di operazioni
    operations
  end

  def parse_operation_text(text, type)
    case type
    when 'addizione', 'sottrazione'
      # Estrai i numeri dall'operazione (es. "234 + 567" o "500 - 123")
      numbers = text.scan(/\d+/).map(&:to_i)
      if numbers.any?
        {
          'values' => numbers,
          'operation_text' => text.strip
        }
      end
    when 'moltiplicazione'
      # Estrai i due fattori (es. "12 x 5" o "12 × 5")
      numbers = text.scan(/\d+/).map(&:to_i)
      if numbers.size >= 2
        {
          'multiplicand' => numbers[0],
          'multiplier' => numbers[1],
          'operation_text' => text.strip
        }
      end
    when 'abaco'
      # Estrai il numero per l'abaco
      number = text.scan(/\d+/).first&.to_i
      if number
        {
          'value' => number,
          'operation_text' => text.strip
        }
      end
    end
  end
end
