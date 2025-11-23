# frozen_string_literal: true

class Strumenti::SottrazioniController < ApplicationController
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

  private

  def default_options
    {
      show_minuend_subtrahend: false,
      show_toolbar: true,
      show_borrow: true,
      show_solution: false
    }
  end

  def parse_options
    {
      show_minuend_subtrahend: params[:show_minuend_subtrahend] == "true",
      show_toolbar: params[:show_toolbar] == "true",
      show_borrow: params[:show_borrow] == "true",
      show_solution: params[:show_solution] == "true"
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
