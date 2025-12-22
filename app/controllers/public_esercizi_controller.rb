class PublicEserciziController < ApplicationController
  disallow_account_scope
  allow_unauthenticated_access

  before_action :set_esercizio_by_token, only: [ :show, :attempt ]
  before_action :set_attempt, only: [ :results ]
  layout "public"

  def show
    # Incrementa il contatore delle visualizzazioni
    @esercizio.increment_views!

    # Crea o recupera un attempt per questo studente
    student_id = session[:student_identifier] ||= SecureRandom.uuid
    @attempt = @esercizio.esercizio_attempts.incomplete.by_student(student_id).first ||
               @esercizio.esercizio_attempts.build(student_identifier: student_id)
  end

  def attempt
    student_id = session[:student_identifier] ||= SecureRandom.uuid

    # Trova o crea un attempt
    @attempt = @esercizio.esercizio_attempts.incomplete.by_student(student_id).first ||
               @esercizio.esercizio_attempts.create!(student_identifier: student_id)

    # Prepara i risultati nel formato corretto
    results_hash = prepare_results_for_scoring

    # Aggiungi il nome dello studente se fornito
    if params[:student_name].present?
      results_hash["student_name"] = params[:student_name]
    end

    # Completa l'attempt con i risultati (passando il tempo dal frontend)
    if @attempt.complete!(results_hash, nil, params[:time_spent])
      redirect_to public_esercizio_results_path(
        share_token: @esercizio.share_token,
        attempt_id: @attempt.id
      ), notice: "Esercizio completato con successo!"
    else
      render :show, alert: "Errore nel completamento dell'esercizio."
    end
  end

  def results
    @esercizio = @attempt.esercizio

    # Verifica che l'attempt sia dello studente corrente
    if session[:student_identifier] != @attempt.student_identifier
      redirect_to root_path, alert: "Non autorizzato a visualizzare questi risultati."
    end
  end

  private

  def set_esercizio_by_token
    @esercizio = Esercizio.find_by_share_token!(params[:share_token])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Esercizio non trovato."
  end

  def set_attempt
    @attempt = EsercizioAttempt.find(params[:attempt_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Tentativo non trovato."
  end

  def prepare_results_for_scoring
    results = { "operations" => [] }

    # Per ogni operazione nell'esercizio
    @esercizio.operations.each do |operation|
      operation_result = {
        "id" => operation["id"],
        "type" => operation["type"],
        "config" => operation["config"]
      }

      # Determina la risposta corretta in base al tipo di operazione
      case operation["type"]
      when "addizione"
        correct_answer = calculate_addition_answer(operation["config"])
        user_answer = collect_addition_response(operation["id"])
      when "sottrazione"
        correct_answer = calculate_subtraction_answer(operation["config"])
        user_answer = collect_subtraction_response(operation["id"])
      when "moltiplicazione"
        correct_answer = calculate_multiplication_answer(operation["config"])
        user_answer = collect_multiplication_response(operation["id"])
      when "abaco"
        correct_answer = operation["config"]["value"] || operation["config"]["correct_value"]
        user_answer = collect_abaco_response(operation["id"])
      else
        correct_answer = nil
        user_answer = nil
      end

      # Confronta la risposta dell'utente con quella corretta
      operation_result["correct_answer"] = correct_answer
      operation_result["user_answer"] = user_answer
      operation_result["correct"] = (user_answer.to_s == correct_answer.to_s) unless correct_answer.nil?

      results["operations"] << operation_result
    end

    results
  end

  def calculate_addition_answer(config)
    return nil unless config

    if config["operation_text"].present?
      numbers = config["operation_text"].scan(/\d+/).map(&:to_i)
      numbers.sum
    elsif config["values"].present? && config["values"].is_a?(Array)
      config["values"].map(&:to_i).sum
    else
      nil
    end
  end

  def calculate_subtraction_answer(config)
    return nil unless config

    if config["operation_text"].present?
      numbers = config["operation_text"].scan(/\d+/).map(&:to_i)
      numbers.first.to_i - numbers[1..-1].sum if numbers.any?
    elsif config["values"].present? && config["values"].is_a?(Array)
      values = config["values"].map(&:to_i)
      values.first - values[1..-1].sum if values.any?
    else
      nil
    end
  end

  def calculate_multiplication_answer(config)
    return nil unless config

    if config["operation_text"].present?
      numbers = config["operation_text"].scan(/\d+/).map(&:to_i)
      numbers.reduce(:*) if numbers.any?
    elsif config["multiplicand"].present? && config["multiplier"].present?
      config["multiplicand"].to_i * config["multiplier"].to_i
    else
      nil
    end
  end

  def collect_addition_response(operation_id)
    # Raccoglie la risposta dall'input del risultato nell'addizione
    # I parametri arrivano come results[operation_id][result][0], results[operation_id][result][1], etc.
    if params[:results] && params[:results][operation_id] && params[:results][operation_id]["result"]
      result_digits = params[:results][operation_id]["result"]
      # Unisci le cifre in un numero (l'ordine è già corretto: indice 0 = cifra più significativa)
      if result_digits.respond_to?(:keys)
        # Ordina per indice e concatena
        sorted_digits = result_digits.keys.sort_by(&:to_i).map { |k| result_digits[k] }
        sorted_digits.join.to_i  # NON invertire, l'ordine è già corretto!
      else
        nil
      end
    else
      nil
    end
  end

  def collect_subtraction_response(operation_id)
    # Stessa logica dell'addizione
    if params[:results] && params[:results][operation_id] && params[:results][operation_id]["result"]
      result_digits = params[:results][operation_id]["result"]
      if result_digits.respond_to?(:keys)
        # Ordina per indice e concatena (NON invertire)
        sorted_digits = result_digits.keys.sort_by(&:to_i).map { |k| result_digits[k] }
        sorted_digits.join.to_i
      else
        nil
      end
    else
      nil
    end
  end

  def collect_multiplication_response(operation_id)
    # Stessa logica dell'addizione
    if params[:results] && params[:results][operation_id] && params[:results][operation_id]["result"]
      result_digits = params[:results][operation_id]["result"]
      if result_digits.respond_to?(:keys)
        # Ordina per indice e concatena (NON invertire)
        sorted_digits = result_digits.keys.sort_by(&:to_i).map { |k| result_digits[k] }
        sorted_digits.join.to_i
      else
        nil
      end
    else
      nil
    end
  end

  def collect_abaco_response(operation_id)
    # Per l'abaco, raccoglie il valore totale
    if params[:results] && params[:results][operation_id] && params[:results][operation_id]["total"]
      params[:results][operation_id]["total"].to_i
    else
      nil
    end
  end
end
