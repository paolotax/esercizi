# frozen_string_literal: true

module Strumenti
  class DivisioniController < BaseController
    def quaderno
      @divisions = []
      @options = default_quaderno_options
    end

    def quaderno_generate
      @divisions_string = params[:divisions]
      @options = parse_quaderno_options
      @divisions = Divisione.build_renderers(@divisions_string, **@options.except(:example_type)) if @divisions_string.present?
      render :quaderno
    end

    def quaderno_preview
      @options = parse_quaderno_options
      esempio_string = @options[:example_type] == "interi" ? "144:12" : "12,5:2,5"
      @esempio_divisione = Divisione.build_renderer(esempio_string, **@options.except(:example_type))
    end

    private

    def default_quaderno_options
      {
        title: nil,
        example_type: "decimali",
        show_dividend_divisor: true,
        show_toolbar: true,
        show_solution: true,
        show_steps: true
      }
    end

    def parse_quaderno_options
      {
        title: params[:title].presence,
        example_type: params[:example_type].presence || "decimali",
        show_dividend_divisor: params[:show_dividend_divisor] == "true",
        show_toolbar: params[:show_toolbar] == "true",
        show_solution: params[:show_solution] == "true",
        show_steps: params[:show_steps] == "true"
      }
    end
  end
end
