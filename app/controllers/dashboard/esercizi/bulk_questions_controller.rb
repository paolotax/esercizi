# frozen_string_literal: true

class Dashboard::Esercizi::BulkQuestionsController < ApplicationController
  require_teacher
  before_action :set_esercizio

  # POST /dashboard/esercizi/:esercizio_id/bulk_questions
  def create
    result = Parseable.create_all_from_text(
      params[:operations_text],
      esercizio: @esercizio,
      options: build_options
    )

    if result[:count].zero?
      redirect_to edit_dashboard_esercizio_path(@esercizio),
                  alert: "Nessuna operazione valida trovata"
    else
      notice = "#{result[:count]} #{result[:count] == 1 ? 'operazione aggiunta' : 'operazioni aggiunte'}"
      redirect_to edit_dashboard_esercizio_path(@esercizio), notice: notice
    end
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
