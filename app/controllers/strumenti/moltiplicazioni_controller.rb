# frozen_string_literal: true

module Strumenti
  class MoltiplicazioniController < BaseController
    def show
      @multiplications = []
      @options = default_options
    end

    def preview
      @options = parse_options
    end

    def create
      @multiplications_string = params[:multiplications]
      @options = parse_options
      renderer_options = @options.except(:example_type).merge(grid_style: @options[:grid_style]&.to_sym || :quaderno)
      @multiplications = Moltiplicazione.build_renderers(@multiplications_string, **renderer_options) if @multiplications_string.present?
      render :show
    end

    private

    def default_options
      {
        title: nil,
        example_type: "decimali",
        grid_style: "quaderno",
        show_multiplicand_multiplier: true,
        show_toolbar: true,
        show_partial_products: true,
        show_solution: true,
        show_labels: true,
        show_carry: true
      }
    end

    def parse_options
      {
        title: params[:title].presence,
        example_type: params[:example_type].presence || "decimali",
        grid_style: params[:grid_style].presence || "quaderno",
        show_multiplicand_multiplier: params[:show_multiplicand_multiplier] == "true",
        show_toolbar: params[:show_toolbar] == "true",
        show_partial_products: params[:show_partial_products] == "true",
        show_solution: params[:show_solution] == "true",
        show_labels: params[:show_labels] == "true",
        show_carry: params[:show_carry] == "true"
      }
    end
  end
end
