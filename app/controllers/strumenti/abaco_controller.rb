class Strumenti::AbacoController < ApplicationController
  def show
    @numbers = params[:numbers] || ""
    @numbers_array = parse_numbers(@numbers) if @numbers.present?
  end

  def examples
    # View con esempi di utilizzo dell'abaco
  end

  private

  def parse_numbers(numbers_string)
    # Supporta più formati:
    # - Semplice: "125" -> numero da completare
    # - Con parametri: "125:k=1,da=nil,u=nil" -> k precompilato, da e u da completare
    # - Con opzioni: "573:editable=false,show_value=false"
    #
    # Separatori: spazio o nuova riga
    # Le virgole sono usate per separare i parametri (es: k=1,da=nil)
    #
    # Parametri supportati:
    # - h, k, da, u: valori iniziali delle colonne (nil = da completare, numero = precompilato)
    # - editable: true/false
    # - show_value: true/false
    # - correct_value: numero corretto (default: il numero stesso)

    numbers_string
      .split(/[\s\n]+/) # Separa per spazi o nuova riga
      .map(&:strip)
      .reject(&:blank?)
      .map { |line| parse_abaco_line(line) }
      .compact
  end

  def parse_abaco_line(line)
    # Formato: "numero:param1=val1,param2=val2"
    parts = line.split(':', 2)
    number_str = parts[0].strip
    params_str = parts[1]&.strip

    # Parse numero
    number = number_str.to_i
    return nil unless number >= 0 && number <= 9999

    # Parametri di default
    result = {
      number: number,
      correct_value: number
    }

    # Parse parametri opzionali
    if params_str.present?
      params_str.split(',').each do |param|
        key, value = param.split('=', 2).map(&:strip)
        next unless key && value

        # Converti valore
        parsed_value = case value.downcase
        when 'nil', 'null', ''
          nil
        when 'true'
          true
        when 'false'
          false
        else
          value.to_i
        end

        result[key.to_sym] = parsed_value
      end
    end

    result
  end
end
