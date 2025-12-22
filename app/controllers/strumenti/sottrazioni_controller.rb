# frozen_string_literal: true

class Strumenti::SottrazioniController < Strumenti::BaseController
  def show
    @sottrazioni = []
    @options = default_options
  end

  def generate
    @operations = params[:operations] || ""
    @options = parse_options

    @sottrazioni = parse_sottrazioni_with_options(@operations, @options) if @operations.present?

    render :show
  end

  def quaderno
    @sottrazioni = []
    @options = default_options
  end

  def quaderno_generate
    @operations = params[:operations] || ""
    @options = parse_options

    @sottrazioni = parse_sottrazioni_with_options(@operations, @options) if @operations.present?

    render :quaderno
  end

  def quaderno_preview
    @options = parse_options
    esempio_operands = @options[:example_type] == "interi" ? [ 487, 258 ] : [ "12,34", "5,67" ]
    @esempio_sottrazione = Sottrazione.new(
      minuend: esempio_operands[0],
      subtrahend: esempio_operands[1],
      title: @options[:title],
      show_minuend_subtrahend: @options[:show_minuend_subtrahend],
      show_toolbar: @options[:show_toolbar],
      show_labels: @options[:show_labels],
      show_solution: @options[:show_solution],
      show_borrow: @options[:show_borrow]
    )
  end

  private

  def default_options
    {
      title: nil,
      example_type: "decimali",
      show_minuend_subtrahend: true,
      show_toolbar: true,
      show_borrow: true,
      show_solution: true,
      show_labels: true
    }
  end

  def parse_options
    {
      title: params[:title].presence,
      example_type: params[:example_type].presence || "decimali",
      show_minuend_subtrahend: params[:show_minuend_subtrahend] == "true",
      show_toolbar: params[:show_toolbar] == "true",
      show_borrow: params[:show_borrow] == "true",
      show_solution: params[:show_solution] == "true",
      show_labels: params[:show_labels] == "true"
    }
  end

  def parse_sottrazioni_with_options(operations_string, options)
    return [] if operations_string.blank?

    Sottrazione.parse_multiple(operations_string).map do |sottrazione|
      Sottrazione.new(
        minuend: sottrazione.minuend,
        subtrahend: sottrazione.subtrahend,
        **options
      )
    end
  end
end
