# frozen_string_literal: true

class Strumenti::AbacoController < ApplicationController
  def show
    @abachi = []
    @options = default_options
  end

  def generate
    @numbers = params[:numbers] || ""
    @options = parse_options

    @abachi = parse_abachi_with_options(@numbers, @options) if @numbers.present?

    render :show
  end

  def examples
    # View con esempi di utilizzo dell'abaco
  end

  private

  def default_options
    {
      editable: true,
      show_value: false
    }
  end

  def parse_options
    {
      editable: params[:editable] == "true",
      show_value: params[:show_value] == "true"
    }
  end

  def parse_abachi_with_options(numbers_string, options)
    return [] if numbers_string.blank?

    numbers_string
      .split(/[\s\n]+/)
      .map(&:strip)
      .reject(&:blank?)
      .map { |line| parse_single_abaco(line, options) }
      .compact
  end

  def parse_single_abaco(line, global_options)
    # Parse il numero (ignora eventuali parametri inline)
    parts = line.strip.split(":", 2)
    number_str = parts[0]
    return nil if number_str.blank?

    number = number_str.to_i
    return nil unless number.between?(0, 9999)

    # Determina quante colonne servono in base al numero
    columns = case number
              when 0..99 then 2
              when 100..999 then 3
              else 4
              end

    # Applica le opzioni globali - correct_value serve per la verifica
    Abaco.new(columns: columns, correct_value: number, **global_options)
  end
end
