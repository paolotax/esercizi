# frozen_string_literal: true

class Strumenti::AbacoController < Strumenti::BaseController
  def show
    @abachi = []
    @options = default_options
  end

  def preview
    @options = parse_options
    @esempio_abaco = Abaco::Renderer.new(
      columns: @options[:columns],
      correct_value: @options[:example_value],
      editable: @options[:editable],
      show_value: @options[:show_value],
      mode: @options[:mode]
    )
  end

  def create
    @numbers = params[:numbers] || ""
    @options = parse_options
    @abachi = build_abachi_from_numbers(@numbers, @options) if @numbers.present?
    render :show
  end

  def examples
    # View con esempi di utilizzo dell'abaco
  end

  private

  def default_options
    {
      columns: 4,
      editable: true,
      show_value: false,
      mode: nil,
      example_value: 1234
    }
  end

  def parse_options
    {
      columns: (params[:columns].presence || 4).to_i.clamp(2, 4),
      editable: params[:editable] != "false",
      show_value: params[:show_value] == "true",
      mode: params[:mode].presence&.to_sym,
      example_value: (params[:example_value].presence || 1234).to_i
    }
  end

  def build_abachi_from_numbers(numbers_string, options)
    return [] if numbers_string.blank?

    numbers_string
      .split(/[\s\n]+/)
      .map(&:strip)
      .reject(&:blank?)
      .map { |line| build_single_abaco(line, options) }
      .compact
  end

  def build_single_abaco(line, global_options)
    # Parse il numero (ignora eventuali parametri inline)
    parts = line.strip.split(":", 2)
    number_str = parts[0]
    return nil if number_str.blank?

    number = number_str.to_i
    return nil unless number.between?(0, 9999)

    # Usa le colonne forzate se specificate, altrimenti determina in base al numero
    columns = if global_options[:columns].present?
                global_options[:columns]
    else
                case number
                when 0..99 then 2
                when 100..999 then 3
                else 4
                end
    end

    # Rimuovi :columns e :example_value dalle opzioni prima di passarle ad Abaco
    abaco_options = global_options.except(:columns, :example_value)

    # Applica le opzioni globali - correct_value serve per la verifica
    Abaco::Renderer.new(columns: columns, correct_value: number, **abaco_options)
  end
end
