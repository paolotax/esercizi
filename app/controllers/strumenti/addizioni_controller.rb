# frozen_string_literal: true

class Strumenti::AddizioniController < ApplicationController
  def show
    @addizioni = []
    @options = default_options
  end

  def generate
    @operations = params[:operations] || ""
    @options = parse_options

    @addizioni = parse_addizioni_with_options(@operations, @options) if @operations.present?

    render :show
  end

  private

  def default_options
    {
      show_addends: false,
      show_toolbar: true,
      show_carry: true,
      show_solution: false
    }
  end

  def parse_options
    {
      show_addends: params[:show_addends] == "true",
      show_toolbar: params[:show_toolbar] == "true",
      show_carry: params[:show_carry] == "true",
      show_solution: params[:show_solution] == "true"
    }
  end

  def parse_addizioni_with_options(operations_string, options)
    return [] if operations_string.blank?

    Addizione.parse_multiple(operations_string).map do |addizione|
      Addizione.new(
        addends: addizione.addends,
        operator: addizione.operator,
        **options
      )
    end
  end
end
