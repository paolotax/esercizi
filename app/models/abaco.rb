# frozen_string_literal: true

# Modello per rappresentare un abaco con le sue configurazioni
#
# Parametri:
#   columns:       Numero di colonne da mostrare (2, 3, o 4)
#   k/h/da/u:      Valori iniziali delle palline (nil = vuoto, 0-9 = valore)
#   editable:      Se l'abaco è modificabile (default: true)
#   correct_value: Valore per la verifica (opzionale)
#   mode:          Modalità esercizio:
#                  - nil    = sincronizzato (palline e input insieme)
#                  - :balls = conta palline (mostra palline, input vuoti)
#                  - :input = rappresenta numero (mostra target, palline vuote)
#   show_value:    Se mostrare il valore totale (default: false)
#   max_per_column: Massimo palline per colonna (default: 9)
#
class Abaco
  attr_reader :columns, :migliaia, :centinaia, :decine, :unita,
              :editable, :show_value, :correct_value, :max_per_column, :mode

  def initialize(columns: 2, **options)
    @columns = columns.to_i.clamp(2, 4)
    @max_per_column = options.fetch(:max_per_column, 9).to_i
    @editable = options.fetch(:editable, true)
    @show_value = options.fetch(:show_value, false)
    @correct_value = options[:correct_value]
    @mode = options[:mode]

    # Valori delle colonne (nil = vuoto)
    @migliaia = options[:k] if @columns >= 4
    @centinaia = options[:h] if @columns >= 3
    @decine = options[:da] if @columns >= 2
    @unita = options[:u]
  end

  # Metodi per verificare quali colonne mostrare
  def show_k?
    @columns >= 4
  end

  def show_h?
    @columns >= 3
  end

  def show_da?
    @columns >= 2
  end

  def show_u?
    true # Sempre mostrata
  end

  # Valori delle palline (0 se nil)
  def migliaia_value
    @migliaia.to_i
  end

  def centinaia_value
    @centinaia.to_i
  end

  def decine_value
    @decine.to_i
  end

  def unita_value
    @unita.to_i
  end

  # Valori degli input (dipende dal mode)
  def input_k
    return nil unless show_k?
    input_value_for(:k, @migliaia)
  end

  def input_h
    return nil unless show_h?
    input_value_for(:h, @centinaia)
  end

  def input_da
    return nil unless show_da?
    input_value_for(:da, @decine)
  end

  def input_u
    return nil unless show_u?
    input_value_for(:u, @unita)
  end

  # Valore totale dalle palline
  def total_value
    migliaia_value * 1000 + centinaia_value * 100 + decine_value * 10 + unita_value
  end

  # Parametri da passare al partial
  def to_partial_params
    { abaco: self }
  end

  # Parsing di una stringa come "columns=3,h=3,da=8,u=6"
  def self.parse(line)
    options = {}

    line.strip.split(",").each do |param|
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
      when "columns"
        options[:columns] = parsed_value
      when "k", "migliaia"
        options[:k] = parsed_value
      when "h", "centinaia"
        options[:h] = parsed_value
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
      when "mode"
        options[:mode] = value&.to_sym
      when "max_per_column"
        options[:max_per_column] = parsed_value
      end
    end

    new(**options)
  end

  private

  def input_value_for(column, value)
    case @mode
    when :balls
      # Mode balls: input vuoti (utente deve scrivere vedendo le palline)
      ""
    when :input
      # Mode input: mostra il valore target da correct_value
      return "" unless @correct_value
      digit = digit_from_correct_value(column)
      digit > 0 ? digit.to_s : ""
    else
      # Default: mostra il valore della pallina se presente
      value.nil? ? "" : value.to_s
    end
  end

  def digit_from_correct_value(column)
    return 0 unless @correct_value
    case column
    when :k then (@correct_value / 1000) % 10
    when :h then (@correct_value / 100) % 10
    when :da then (@correct_value / 10) % 10
    when :u then @correct_value % 10
    else 0
    end
  end
end
