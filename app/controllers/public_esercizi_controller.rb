class PublicEserciziController < ApplicationController
  before_action :set_esercizio_by_token, only: [:show, :attempt]
  before_action :set_attempt, only: [:results]
  layout 'public'

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

    # Completa l'attempt con i risultati
    if @attempt.complete!(params[:results], params[:score])
      redirect_to public_esercizio_results_path(
        share_token: @esercizio.share_token,
        attempt_id: @attempt.id
      ), notice: 'Esercizio completato con successo!'
    else
      render :show, alert: 'Errore nel completamento dell\'esercizio.'
    end
  end

  def results
    @esercizio = @attempt.esercizio

    # Verifica che l'attempt sia dello studente corrente
    if session[:student_identifier] != @attempt.student_identifier
      redirect_to root_path, alert: 'Non autorizzato a visualizzare questi risultati.'
    end
  end

  private

  def set_esercizio_by_token
    @esercizio = Esercizio.find_by_share_token!(params[:share_token])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Esercizio non trovato.'
  end

  def set_attempt
    @attempt = EsercizioAttempt.find(params[:attempt_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Tentativo non trovato.'
  end
end
