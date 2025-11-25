# frozen_string_literal: true

class ExercisesController < ApplicationController
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
            operands: [parts[0].to_i, parts[1].to_i],
            show_borrow: show_borrow,
            show_carry: show_carry,
            show_operands: show_operands
          }
        elsif op.match?(/[x×*]/i)
          parts = op.split(/[x×*]/i)
          next nil unless parts.length == 2
          {
            type: "multiplication",
            operands: [parts[0].to_i, parts[1].to_i],
            show_operands: show_operands
          }
        elsif op.include?("+")
          parts = op.split("+")
          next nil unless parts.length == 2
          {
            type: "addition",
            operands: [parts[0].to_i, parts[1].to_i],
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
end
