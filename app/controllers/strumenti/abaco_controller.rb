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

    # Applica le opzioni globali
    Abaco.new(number: number, **global_options)
  end
end
