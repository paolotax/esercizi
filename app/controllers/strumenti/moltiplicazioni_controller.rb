# frozen_string_literal: true

module Strumenti
  class MoltiplicazioniController < BaseController
    def show
      @multiplications = []
      @options = default_options
    end

    def generate
      @multiplications_string = params[:multiplications]
      @options = parse_options
      @multiplications = Moltiplicazione.build_renderers(@multiplications_string, **@options.merge(grid_style: :column)) if @multiplications_string.present?
      render :show
    end

    def examples
      # Pagina con esempi di utilizzo
    end

    def quaderno
      @multiplications = []
      @options = default_quaderno_options
    end

    def quaderno_generate
      @multiplications_string = params[:multiplications]
      @options = parse_quaderno_options
      renderer_options = @options.except(:example_type).merge(grid_style: @options[:grid_style]&.to_sym || :quaderno)
      @multiplications = Moltiplicazione.build_renderers(@multiplications_string, **renderer_options) if @multiplications_string.present?
      render :quaderno
    end

    def quaderno_preview
      @options = parse_quaderno_options
      esempio_string = @options[:example_type] == "interi" ? "123x45" : "12,3x4,5"
      @esempio_moltiplicazione = Moltiplicazione.build_renderer(esempio_string, **@options.except(:example_type))
    end

    private

    def default_options
      {
        show_toolbar: true,
        show_partial_products: false,
        show_multiplicand_multiplier: true,
        show_solution: false,
        show_labels: true
      }
    end

    def default_quaderno_options
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
        show_toolbar: params[:show_toolbar] == "true",
        show_partial_products: params[:show_partial_products] == "true",
        show_multiplicand_multiplier: params[:show_multiplicand_multiplier] == "true",
        show_solution: params[:show_solution] == "true",
        show_labels: params[:show_labels] == "true"
      }
    end

    def parse_quaderno_options
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
