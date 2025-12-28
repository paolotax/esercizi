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

    generic_options = build_options

    created_count = 0
    parsed.each do |op|
      klass = op[:type].constantize
      # Normalizza opzioni generiche in specifiche per questo tipo
      specific_options = klass.normalize_options(generic_options)
      questionable = klass.create!(data: op[:data].merge(specific_options))
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
      show_operands: params.dig(:options, :show_operands) == "1",
      show_solution: params.dig(:options, :show_solution) == "1",
      show_toolbar: params.dig(:options, :show_toolbar) == "1",
      show_labels: params.dig(:options, :show_labels) == "1",
      show_carry: params.dig(:options, :show_carry) == "1",
      show_steps: params.dig(:options, :show_steps) == "1",
      layout: params.dig(:options, :layout).presence || "quaderno"
    }
  end
end
