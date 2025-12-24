# frozen_string_literal: true

class Strumenti::AddizioniController < Strumenti::BaseController
  def show
    @addizioni = []
    @options = default_options
  end

  def preview
    @options = parse_options
  end

  def create
    @operations = params[:operations] || ""
    @options = parse_options
    renderer_options = @options.merge(grid_style: @options[:grid_style]&.to_sym || :quaderno)
    @addizioni = Addizione.build_renderers(@operations, **renderer_options) if @operations.present?
    render :show
  end

  private

  def default_options
    {
      title: nil,
      example_type: "decimali",
      grid_style: "quaderno",
      show_addends: true,
      show_toolbar: true,
      show_carry: true,
      show_solution: true,
      show_labels: true
    }
  end

  def parse_options
    {
      title: params[:title].presence,
      example_type: params[:example_type].presence || "decimali",
      grid_style: params[:grid_style].presence || "quaderno",
      show_addends: params[:show_addends] == "true",
      show_toolbar: params[:show_toolbar] == "true",
      show_carry: params[:show_carry] == "true",
      show_solution: params[:show_solution] == "true",
      show_labels: params[:show_labels] == "true"
    }
  end
end
