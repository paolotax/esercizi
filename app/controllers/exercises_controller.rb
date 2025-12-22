# frozen_string_literal: true

class ExercisesController < ApplicationController
  allow_any_account_scope

  # GET /exercises/column_operations_grid
  # Endpoint unificato per qualsiasi tipo di operazione (addizioni, sottrazioni, moltiplicazioni, miste)
  # Supporta anche la prova (sottrazione + addizione per verificare)
  def column_operations_grid
    operations_param = params[:operations]
    with_proof = params[:with_proof] == "true"
    show_carry = params[:show_carry] == "true"
    show_borrow = params[:show_borrow] == "true"
    # show_operands: se false, minuendo/sottraendo o addendi sono vuoti (esercizio da compilare)
    show_operands = params[:show_operands] != "false"

    @operations = []

    if operations_param.present?
      # Formato: "714-354,681-159,..." oppure "345+253,382+216,..." oppure "36x12,37x14,..."
      @operations = operations_param.split(",").map do |op|
        op = op.strip
        if op.include?("-")
          parts = op.split("-")
          next nil unless parts.length == 2
          {
            type: "subtraction",
            operands: [ parts[0].to_i, parts[1].to_i ],
            show_borrow: show_borrow,
            show_carry: show_carry,
            show_operands: show_operands
          }
        elsif op.match?(/[x×*]/i)
          parts = op.split(/[x×*]/i)
          next nil unless parts.length == 2
          {
            type: "multiplication",
            operands: [ parts[0].to_i, parts[1].to_i ],
            show_operands: show_operands
          }
        elsif op.include?("+")
          parts = op.split("+")
          next nil unless parts.length == 2
          {
            type: "addition",
            operands: [ parts[0].to_i, parts[1].to_i ],
            show_carry: show_carry,
            show_borrow: show_borrow,
            show_operands: show_operands
          }
        end
      end.compact
    end

    render partial: "exercises/column_operations_grid",
           locals: { operations: @operations, with_proof: with_proof }
  end

  # GET /exercises/quaderno_grid
  # Endpoint per caricare un singolo partial quaderno (per la sidebar)
  # Parametri:
  # - operation: l'operazione (es. "234+567", "500-123", "45x12", "144:12")
  # - type: tipo di operazione (addizione, sottrazione, moltiplicazione, divisione)
  def quaderno_grid
    operation = params[:operation]
    type = params[:type] || "addizione"

    case type
    when "addizione"
      numbers = parse_addends(operation)
      return render_error("Operazione non valida") unless numbers&.length >= 2
      addizione = Addizione.new(addends: numbers, show_toolbar: true, show_addends: true)
      render partial: "strumenti/addizioni/quaderno_addizione", locals: { addizione: addizione }

    when "sottrazione"
      numbers = parse_operation_strings(operation, "-")
      return render_error("Operazione non valida") unless numbers&.length == 2
      sottrazione = Sottrazione.new(minuend: numbers[0], subtrahend: numbers[1], show_toolbar: true, show_minuend_subtrahend: true)
      render partial: "strumenti/sottrazioni/quaderno_sottrazione", locals: { sottrazione: sottrazione }

    when "moltiplicazione"
      numbers = parse_operation_strings(operation, /[x×*]/i)
      return render_error("Operazione non valida") unless numbers&.length == 2
      show_carry = params[:show_partial_carries] == "true"
      moltiplicazione = Moltiplicazione.new(multiplicand: numbers[0], multiplier: numbers[1], show_toolbar: true, show_carry: show_carry)
      render partial: "strumenti/moltiplicazioni/quaderno_moltiplicazione", locals: { moltiplicazione: moltiplicazione }

    when "divisione"
      numbers = parse_operation_strings(operation, /[÷:\/]/)
      return render_error("Operazione non valida") unless numbers&.length == 2
      extra_zeros = (params[:extra_zeros] || 1).to_i  # Default 1 zero extra per continuare la divisione
      divisione = Divisione.new(dividend: numbers[0], divisor: numbers[1], show_toolbar: true, extra_zeros: extra_zeros)
      render partial: "strumenti/divisioni/quaderno_divisione", locals: { divisione: divisione }

    else
      render_error("Tipo di operazione non supportato")
    end
  end

  private

  def parse_operation(operation, separator)
    return nil unless operation.present?
    parts = operation.split(separator)
    return nil unless parts.length == 2
    parts.map { |p| p.strip.to_i }
  end

  # Versione che mantiene le stringhe (per decimali con virgola)
  def parse_operation_strings(operation, separator)
    return nil unless operation.present?
    parts = operation.split(separator)
    return nil unless parts.length == 2
    parts.map(&:strip)
  end

  # Parse addendi multipli (supporta 2 o più addendi)
  def parse_addends(operation)
    return nil unless operation.present?
    parts = operation.split("+")
    return nil unless parts.length >= 2
    parts.map(&:strip)
  end

  def render_error(message)
    render plain: "<div class='text-center py-8 text-red-500'>#{message}</div>", status: :unprocessable_entity
  end
end
