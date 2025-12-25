# frozen_string_literal: true

class ExercisesController < ApplicationController
  allow_any_account_scope

  # GET /exercises/operation_grid
  # Endpoint unificato per caricare griglie di operazioni (singole o multiple)
  # Supporta tutti i tipi: addizione, sottrazione, moltiplicazione, divisione
  # Supporta entrambi i layout: quaderno (default) e column
  #
  # Parametri:
  # - operations: stringa operazioni separate da virgola (es. "234+567,100-50" o "234+567")
  # - type: opzionale, forza il tipo (addizione, sottrazione, moltiplicazione, divisione)
  #         se non specificato, deduce dal simbolo (+, -, x, :)
  # - layout: "quaderno" (default, stile quadretti) o "column" (bordo colorato)
  # - show_toolbar: true/false (default true)
  # - show_operands: true/false (default true)
  # - show_carry: true/false (default false)
  # - show_borrow: true/false (default false)
  def operation_grid
    operations_param = params[:operations]
    layout = (params[:layout] || "quaderno").to_sym
    show_toolbar = params[:show_toolbar] != "false"
    show_operands = params[:show_operands] != "false"
    show_carry = params[:show_carry] == "true"
    show_borrow = params[:show_borrow] == "true"
    forced_type = params[:type]

    return render_error("Operazione non specificata") if operations_param.blank?

    # Parse delle operazioni
    operations = operations_param.split(",").map(&:strip)

    # Genera i grid per ogni operazione
    grids = operations.filter_map do |op|
      type = forced_type || detect_operation_type(op)
      build_operation_grid(op, type, layout: layout, show_toolbar: show_toolbar,
                           show_operands: show_operands, show_carry: show_carry, show_borrow: show_borrow)
    end

    return render_error("Nessuna operazione valida") if grids.empty?

    # Render dei partial
    render partial: "exercises/operation_grids", locals: { grids: grids, layout: layout }
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
      addizione = Addizione::Renderer.new(addends: numbers, show_toolbar: true, show_addends: true)
      grid = addizione.to_grid_matrix
      render partial: "strumenti/addizioni/addizione_grid", locals: { grid: grid }

    when "sottrazione"
      numbers = parse_operation_strings(operation, "-")
      return render_error("Operazione non valida") unless numbers&.length == 2
      sottrazione = Sottrazione::Renderer.new(minuend: numbers[0], subtrahend: numbers[1], show_toolbar: true, show_minuend_subtrahend: true)
      grid = sottrazione.to_grid_matrix
      render partial: "strumenti/sottrazioni/sottrazione_grid", locals: { grid: grid }

    when "moltiplicazione"
      numbers = parse_operation_strings(operation, /[x×*]/i)
      return render_error("Operazione non valida") unless numbers&.length == 2
      show_carry = params[:show_partial_carries] == "true"
      moltiplicazione = Moltiplicazione::Renderer.new(multiplicand: numbers[0], multiplier: numbers[1], show_toolbar: true, show_carry: show_carry)
      grid = moltiplicazione.to_grid_matrix
      render partial: "strumenti/moltiplicazioni/moltiplicazione_grid", locals: { grid: grid }

    when "divisione"
      numbers = parse_operation_strings(operation, /[÷:\/]/)
      return render_error("Operazione non valida") unless numbers&.length == 2
      extra_zeros = (params[:extra_zeros] || 1).to_i  # Default 1 zero extra per continuare la divisione
      divisione = Divisione::Renderer.new(dividend: numbers[0], divisor: numbers[1], show_toolbar: true, extra_zeros: extra_zeros)
      grid = divisione.to_grid_matrix
      render partial: "strumenti/divisioni/divisione_grid", locals: { grid: grid }

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

  # Rileva il tipo di operazione dal simbolo
  def detect_operation_type(operation)
    if operation.match?(/[÷:\/]/)
      "divisione"
    elsif operation.match?(/[x×*]/i)
      "moltiplicazione"
    elsif operation.include?("-")
      "sottrazione"
    else
      "addizione"
    end
  end

  # Costruisce il grid per una singola operazione
  def build_operation_grid(operation, type, layout:, show_toolbar:, show_operands:, show_carry:, show_borrow:)
    grid_style = layout == :column ? :column : :quaderno

    case type
    when "addizione"
      numbers = parse_addends(operation)
      return nil unless numbers&.length >= 2
      renderer = Addizione::Renderer.new(
        addends: numbers,
        show_toolbar: show_toolbar,
        show_addends: show_operands,
        show_carry: show_carry,
        grid_style: grid_style
      )
      { type: "addizione", grid: renderer.to_grid_matrix, partial: "strumenti/addizioni/addizione_grid" }

    when "sottrazione"
      numbers = parse_operation_strings(operation, "-")
      return nil unless numbers&.length == 2
      renderer = Sottrazione::Renderer.new(
        minuend: numbers[0],
        subtrahend: numbers[1],
        show_toolbar: show_toolbar,
        show_minuend_subtrahend: show_operands,
        show_borrow: show_borrow,
        grid_style: grid_style
      )
      { type: "sottrazione", grid: renderer.to_grid_matrix, partial: "strumenti/sottrazioni/sottrazione_grid" }

    when "moltiplicazione"
      numbers = parse_operation_strings(operation, /[x×*]/i)
      return nil unless numbers&.length == 2
      renderer = Moltiplicazione::Renderer.new(
        multiplicand: numbers[0],
        multiplier: numbers[1],
        show_toolbar: show_toolbar,
        show_multiplicand_multiplier: show_operands,
        show_carry: show_carry,
        grid_style: grid_style
      )
      { type: "moltiplicazione", grid: renderer.to_grid_matrix, partial: "strumenti/moltiplicazioni/moltiplicazione_grid" }

    when "divisione"
      numbers = parse_operation_strings(operation, /[÷:\/]/)
      return nil unless numbers&.length == 2
      renderer = Divisione::Renderer.new(
        dividend: numbers[0],
        divisor: numbers[1],
        show_toolbar: show_toolbar,
        show_dividend_divisor: show_operands,
        grid_style: grid_style
      )
      { type: "divisione", grid: renderer.to_grid_matrix, partial: "strumenti/divisioni/divisione_grid" }

    else
      nil
    end
  end
end
