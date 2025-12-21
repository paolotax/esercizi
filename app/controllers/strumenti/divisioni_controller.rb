# frozen_string_literal: true

module Strumenti
  class DivisioniController < ApplicationController
    def quaderno
      @divisions = []
      @options = default_quaderno_options
    end

    def quaderno_generate
      @divisions_string = params[:divisions]
      @options = parse_quaderno_options

      @divisions = parse_divisions_with_options(@divisions_string, @options)

      render :quaderno
    end

    def quaderno_preview
      @options = parse_quaderno_options
      esempio_operands = @options[:example_type] == "interi" ? [ 144, 12 ] : [ "12,5", "2,5" ]
      @esempio_divisione = Divisione.new(
        dividend: esempio_operands[0],
        divisor: esempio_operands[1],
        title: @options[:title],
        show_dividend_divisor: @options[:show_dividend_divisor],
        show_toolbar: @options[:show_toolbar],
        show_solution: @options[:show_solution],
        show_steps: @options[:show_steps]
      )
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

    def parse_divisions_with_options(divisions_string, options)
      return [] if divisions_string.blank?

      divisions_string
        .split(/[\n;]+/)
        .map(&:strip)
        .reject(&:blank?)
        .map { |line| parse_single_division(line, options) }
        .compact
    end

    def parse_single_division(line, global_options)
      # Parse solo i numeri (ignora eventuali parametri inline)
      numbers_str = line.split(":", 2).first
      return nil if numbers_str.blank?

      # Supporta numeri decimali con virgola o punto
      # Operatori: : / ÷
      match = numbers_str.match(/^(\d+([.,]\d+)?)\s*[:\÷\/]\s*(\d+([.,]\d+)?)$/i)
      return nil unless match

      begin
        Divisione.new(
          dividend: match[1],
          divisor: match[3],
          **global_options
        )
      rescue ArgumentError
        nil
      end
    end
  end
end
