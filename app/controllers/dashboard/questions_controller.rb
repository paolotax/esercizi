# frozen_string_literal: true

class Dashboard::QuestionsController < ApplicationController
  require_teacher

  before_action :set_esercizio
  before_action :set_question, only: [:edit, :update, :destroy]

  def create
    @question = @esercizio.questions.build(question_params)
    @question.questionable = build_questionable
    @question.creator = Current.user
    @question.account = Current.account
    @question.position = @esercizio.questions.maximum(:position).to_i + 1

    if @question.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_dashboard_esercizio_path(@esercizio), notice: "Domanda aggiunta." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("question_form", partial: "dashboard/questions/form", locals: { esercizio: @esercizio, question: @question }) }
        format.html { redirect_to edit_dashboard_esercizio_path(@esercizio), alert: "Errore nell'aggiunta della domanda." }
      end
    end
  end

  def edit
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def update
    if @question.questionable.update(data: question_data_params)
      @question.update(question_params) if params[:question].present?

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_dashboard_esercizio_path(@esercizio), notice: "Domanda aggiornata." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@question), partial: "dashboard/questions/form", locals: { esercizio: @esercizio, question: @question }) }
        format.html { redirect_to edit_dashboard_esercizio_path(@esercizio), alert: "Errore nell'aggiornamento." }
      end
    end
  end

  def destroy
    @question.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@question) }
      format.html { redirect_to edit_dashboard_esercizio_path(@esercizio), notice: "Domanda eliminata." }
    end
  end

  def reorder
    params[:question_ids].each_with_index do |id, index|
      @esercizio.questions.find(id).update_column(:position, index)
    end

    head :ok
  end

  private

  def set_esercizio
    @esercizio = Esercizio.find(params[:esercizio_id])
  end

  def set_question
    @question = @esercizio.questions.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:position, :points, :difficulty) if params[:question].present?
  end

  def question_data_params
    params[:data]&.to_unsafe_h || {}
  end

  def build_questionable
    type = params[:questionable_type] || params.dig(:question, :questionable_type)
    data = params[:data]&.to_unsafe_h || {}
    type.constantize.create!(data: data)
  end
end
