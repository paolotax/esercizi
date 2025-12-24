# frozen_string_literal: true

module Strumenti
  class DivisioniController < BaseController
    def show
      @divisions = []
      @options = default_options
    end

    def preview
      @options = parse_options
    end

    def create
      @divisions_string = params[:divisions]
      @options = parse_options
      @divisions = Divisione.build_renderers(@divisions_string, **@options.except(:example_type)) if @divisions_string.present?
      render :show
    end

    private

    def default_options
      {
        title: nil,
        example_type: "decimali",
        show_dividend_divisor: true,
        show_toolbar: true,
        show_solution: true,
        show_steps: true
      }
    end

    def parse_options
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
