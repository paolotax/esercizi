# frozen_string_literal: true

class PublicEserciziController < ApplicationController
  disallow_account_scope
  allow_unauthenticated_access

  before_action :set_esercizio_by_token, only: [ :show, :attempt ]
  before_action :set_attempt, only: [ :results ]
  layout "public"

  def show
    @esercizio.increment_views!

    student_id = session[:student_identifier] ||= SecureRandom.uuid
    @attempt = @esercizio.esercizio_attempts.incomplete.by_student(student_id).first ||
               @esercizio.esercizio_attempts.build(student_identifier: student_id)
  end

  def attempt
    student_id = session[:student_identifier] ||= SecureRandom.uuid

    @attempt = @esercizio.esercizio_attempts.incomplete.by_student(student_id).first ||
               @esercizio.esercizio_attempts.create!(student_identifier: student_id)

    results_hash = prepare_results_for_scoring

    if params[:student_name].present?
      results_hash["student_name"] = params[:student_name]
    end

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

    if session[:student_identifier] != @attempt.student_identifier
      redirect_to root_path, alert: "Non autorizzato a visualizzare questi risultati."
    end
  end

  private

  def set_esercizio_by_token
    @esercizio = Esercizio.includes(questions: :questionable).find_by_share_token!(params[:share_token])

    unless @esercizio.published?
      redirect_to root_path, alert: "Esercizio non disponibile."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Esercizio non trovato."
  end

  def set_attempt
    @attempt = EsercizioAttempt.find(params[:attempt_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Tentativo non trovato."
  end

  def prepare_results_for_scoring
    results = { "questions" => [] }

    @esercizio.questions.each do |question|
      questionable = question.questionable
      data = questionable.data.with_indifferent_access

      question_result = {
        "id" => question.id,
        "type" => question.questionable_type.downcase,
        "data" => data
      }

      case question.questionable_type
      when "Addizione"
        correct_answer = calculate_addition_answer(data)
        user_answer = collect_question_response(question.id)
      when "Sottrazione"
        correct_answer = calculate_subtraction_answer(data)
        user_answer = collect_question_response(question.id)
      when "Moltiplicazione"
        correct_answer = calculate_multiplication_answer(data)
        user_answer = collect_question_response(question.id)
      when "Divisione"
        correct_answer = calculate_division_answer(data)
        user_answer = collect_question_response(question.id)
      when "Abaco"
        correct_answer = data[:value].to_i
        user_answer = collect_abaco_response(question.id)
      else
        correct_answer = nil
        user_answer = nil
      end

      question_result["correct_answer"] = correct_answer
      question_result["user_answer"] = user_answer
      question_result["correct"] = (user_answer.to_s == correct_answer.to_s) unless correct_answer.nil?

      results["questions"] << question_result
    end

    results
  end

  def calculate_addition_answer(data)
    addends = data[:addends] || []
    addends.map(&:to_i).sum
  end

  def calculate_subtraction_answer(data)
    minuend = data[:minuend].to_i
    subtrahend = data[:subtrahend].to_i
    minuend - subtrahend
  end

  def calculate_multiplication_answer(data)
    multiplicand = data[:multiplicand].to_i
    multiplier = data[:multiplier].to_i
    multiplicand * multiplier
  end

  def calculate_division_answer(data)
    dividend = data[:dividend].to_i
    divisor = data[:divisor].to_i
    divisor.zero? ? nil : dividend / divisor
  end

  def collect_question_response(question_id)
    if params[:results] && params[:results][question_id.to_s] && params[:results][question_id.to_s]["result"]
      result_digits = params[:results][question_id.to_s]["result"]
      if result_digits.respond_to?(:keys)
        sorted_digits = result_digits.keys.sort_by(&:to_i).map { |k| result_digits[k] }
        sorted_digits.join.to_i
      else
        nil
      end
    else
      nil
    end
  end

  def collect_abaco_response(question_id)
    if params[:results] && params[:results][question_id.to_s] && params[:results][question_id.to_s]["total"]
      params[:results][question_id.to_s]["total"].to_i
    else
      nil
    end
  end
end
