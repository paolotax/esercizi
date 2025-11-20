# frozen_string_literal: true

# Modello per rappresentare un abaco con le sue configurazioni
class Abaco
  attr_reader :number, :migliaia, :centinaia, :decine, :unita,
              :editable, :show_value, :correct_value, :disable_auto_zeros

  def initialize(number:, **options)
    @number = number
    @correct_value = options[:correct_value] || number

    # Estrai le cifre dal numero
    h_digit = (number / 1000) % 10
    k_digit = (number / 100) % 10
    da_digit = (number / 10) % 10
    u_digit = number % 10

    # Controlla se ci sono parametri espliciti per le colonne
    has_explicit_params = options.key?(:h) || options.key?(:k) || options.key?(:da) || options.key?(:u)

    # Determina quali colonne mostrare in base al numero
    show_migliaia = number >= 1000
    show_centinaia = number >= 100
    show_decine = number >= 10
    show_unita = true # Sempre mostrata

    # Se ci sono parametri espliciti, usa quelli; altrimenti tutto nil (da completare)
    if has_explicit_params
      # Mostra le colonne necessarie, usando i valori specificati o nil
      @migliaia = options[:h] if show_migliaia
      @centinaia = options[:k] if show_centinaia
      @decine = options[:da] if show_decine
      @unita = options[:u] if show_unita
    else
      # Nessun parametro esplicito: mostra le colonne necessarie ma tutte vuote (nil)
      @migliaia = nil if show_migliaia
      @centinaia = nil if show_centinaia
      @decine = nil if show_decine
      @unita = nil if show_unita
    end

    @editable = options.fetch(:editable, true)
    @show_value = options.fetch(:show_value, false)
    @disable_auto_zeros = has_explicit_params
  end

  # Parsing di una stringa come "125:k=1,da=nil,u=nil"
  def self.parse(line)
    parts = line.strip.split(":", 2)
    number_str = parts[0]
    params_str = parts[1]

    return nil if number_str.blank?

    number = number_str.to_i
    return nil unless number.between?(0, 9999)

    options = { number: number }

    # Parse parametri se presenti
    if params_str.present?
      params_str.split(",").each do |param|
        key, value = param.split("=", 2).map(&:strip)
        next if key.blank?

        parsed_value = case value&.downcase
        when "nil", "null", ""
          nil
        when "true"
          true
        when "false"
          false
        else
          value.to_i
        end

        case key.downcase
        when "h", "migliaia"
          options[:h] = parsed_value
        when "k", "centinaia"
          options[:k] = parsed_value
        when "da", "decine"
          options[:da] = parsed_value
        when "u", "unita"
          options[:u] = parsed_value
        when "editable"
          options[:editable] = parsed_value
        when "show_value"
          options[:show_value] = parsed_value
        when "correct_value"
          options[:correct_value] = parsed_value
        end
      end
    end

    new(**options)
  end

  # Parsing di una stringa con più numeri separati da spazi/newline
  def self.parse_multiple(numbers_string)
    return [] if numbers_string.blank?

    numbers_string
      .split(/[\s\n]+/)
      .map(&:strip)
      .reject(&:blank?)
      .map { |line| parse(line) }
      .compact
  end

  # Parametri da passare al partial _abaco
  def to_partial_params
    params = {}

    # Includi le colonne solo se sono state definite (anche se nil)
    params[:migliaia] = @migliaia if defined?(@migliaia)
    params[:centinaia] = @centinaia if defined?(@centinaia)
    params[:decine] = @decine if defined?(@decine)
    params[:unita] = @unita if defined?(@unita)

    # Altri parametri (sempre inclusi)
    params[:editable] = @editable
    params[:show_value] = @show_value
    params[:correct_value] = @correct_value
    params[:disable_auto_zeros] = @disable_auto_zeros

    params
  end
end
