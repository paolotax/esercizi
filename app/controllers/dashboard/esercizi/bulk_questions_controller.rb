# frozen_string_literal: true

class Dashboard::Esercizi::BulkQuestionsController < ApplicationController
  require_teacher
  before_action :set_esercizio

  # POST /dashboard/esercizi/:esercizio_id/bulk_questions
  def create
    parsed = OperationParser.parse_all(params[:operations_text])

    if parsed.empty?
      redirect_to edit_dashboard_esercizio_path(@esercizio),
                  alert: "Nessuna operazione valida trovata"
      return
    end

    options = build_options

    created_count = 0
    parsed.each do |op|
      klass = op[:type].constantize
      questionable = klass.create!(data: op[:data].merge(options))
      @esercizio.questions.create!(
        questionable: questionable,
        position: @esercizio.questions.count,
        account: Current.account,
        creator: Current.user
      )
      created_count += 1
    end

    redirect_to edit_dashboard_esercizio_path(@esercizio),
                notice: "#{created_count} #{created_count == 1 ? 'operazione aggiunta' : 'operazioni aggiunte'}"
  end

  private

  def set_esercizio
    @esercizio = Esercizio.find(params[:esercizio_id])
  end

  def build_options
    {
      show_toolbar: params.dig(:options, :show_toolbar) == "1",
      show_solution: params.dig(:options, :show_solution) == "1"
    }
  end
end
