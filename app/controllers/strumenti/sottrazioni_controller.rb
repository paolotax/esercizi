# frozen_string_literal: true

class Strumenti::SottrazioniController < Strumenti::BaseController
  def show
    @sottrazioni = []
    @options = default_options
  end

  def generate
    @operations = params[:operations] || ""
    @options = parse_options.merge(grid_style: :column)
    @sottrazioni = Sottrazione.build_renderers(@operations, **@options) if @operations.present?
    render :show
  end

  def quaderno
    @sottrazioni = []
    @options = default_options
  end

  def quaderno_generate
    @operations = params[:operations] || ""
    @options = parse_options
    renderer_options = @options.merge(grid_style: @options[:grid_style]&.to_sym || :quaderno)
    @sottrazioni = Sottrazione.build_renderers(@operations, **renderer_options) if @operations.present?
    render :quaderno
  end

  def quaderno_preview
    @options = parse_options
    esempio_string = @options[:example_type] == "interi" ? "487 - 258" : "12,34 - 5,67"
    @esempio_sottrazione = Sottrazione.build_renderer(esempio_string, **@options.except(:example_type))
  end

  private

  def default_options
    {
      title: nil,
      example_type: "decimali",
      grid_style: "quaderno",
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
      grid_style: params[:grid_style].presence || "quaderno",
      show_minuend_subtrahend: params[:show_minuend_subtrahend] == "true",
      show_toolbar: params[:show_toolbar] == "true",
      show_borrow: params[:show_borrow] == "true",
      show_solution: params[:show_solution] == "true",
      show_labels: params[:show_labels] == "true"
    }
  end
end
