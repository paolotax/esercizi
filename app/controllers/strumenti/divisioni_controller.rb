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

    private

    def default_quaderno_options
      {
        show_dividend_divisor: false,
        show_toolbar: true,
        show_solution: false,
        show_steps: false
      }
    end

    def parse_quaderno_options
      {
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
