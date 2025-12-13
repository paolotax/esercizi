# frozen_string_literal: true

module Strumenti
  class MoltiplicazioniController < ApplicationController
    def show
      @multiplications = []
      @options = default_options
    end

    def generate
      @multiplications_string = params[:multiplications]
      @options = parse_options

      # Crea le moltiplicazioni applicando le opzioni globali
      @multiplications = parse_multiplications_with_options(@multiplications_string, @options)

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

      @multiplications = parse_multiplications_with_options(@multiplications_string, @options)

      render :quaderno
    end

    private

    def default_options
      {
        show_toolbar: true,
        show_partial_products: false,
        editable: true,
        show_exercise: false
      }
    end

    def default_quaderno_options
      {
        show_multiplicand_multiplier: false,
        show_toolbar: true,
        show_partial_products: false,
        show_solution: false,
        show_labels: false
      }
    end

    def parse_options
      {
        show_toolbar: params[:show_toolbar] == "true",
        show_partial_products: params[:show_partial_products] == "true",
        editable: params[:editable] == "true",
        show_exercise: params[:show_exercise] == "true"
      }
    end

    def parse_quaderno_options
      {
        show_multiplicand_multiplier: params[:show_multiplicand_multiplier] == "true",
        show_toolbar: params[:show_toolbar] == "true",
        show_partial_products: params[:show_partial_products] == "true",
        show_solution: params[:show_solution] == "true",
        show_labels: params[:show_labels] == "true"
      }
    end

    def parse_multiplications_with_options(multiplications_string, options)
      return [] if multiplications_string.blank?

      multiplications_string
        .split(/[\s\n]+/)
        .map(&:strip)
        .reject(&:blank?)
        .map { |line| parse_single_multiplication(line, options) }
        .compact
    end

    def parse_single_multiplication(line, global_options)
      # Parse solo i numeri (ignora eventuali parametri inline)
      numbers_str = line.split(":", 2).first
      return nil if numbers_str.blank?

      # Supporta numeri decimali con virgola o punto
      match = numbers_str.match(/^(\d+([.,]\d+)?)\s*[x*×]\s*(\d+([.,]\d+)?)$/i)
      return nil unless match

      Moltiplicazione.new(
        multiplicand: match[1],
        multiplier: match[3],
        **global_options
      )
    end
  end
end
