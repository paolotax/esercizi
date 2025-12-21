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

  def quaderno
    @addizioni = []
    @options = default_options
  end

  def quaderno_generate
    @operations = params[:operations] || ""
    @options = parse_options

    @addizioni = parse_addizioni_with_options(@operations, @options) if @operations.present?

    render :quaderno
  end

  def quaderno_preview
    @options = parse_options
    esempio_addends = @options[:example_type] == "interi" ? [ 234, 567 ] : [ "12,34", "5,67" ]
    @esempio_addizione = Addizione.new(
      addends: esempio_addends,
      title: @options[:title],
      show_addends: @options[:show_addends],
      show_toolbar: @options[:show_toolbar],
      show_labels: @options[:show_labels],
      show_solution: @options[:show_solution],
      show_carry: @options[:show_carry]
    )
  end

  private

  def default_options
    {
      title: nil,
      example_type: "decimali",
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
      show_addends: params[:show_addends] == "true",
      show_toolbar: params[:show_toolbar] == "true",
      show_carry: params[:show_carry] == "true",
      show_solution: params[:show_solution] == "true",
      show_labels: params[:show_labels] == "true"
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
