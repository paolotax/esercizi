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
    # - Un numero per riga: "125\n36\n573"
    # - Numeri separati da virgola: "125, 36, 573"
    # - Numeri separati da punto e virgola: "125; 36; 573"

    numbers_string
      .split(/[,;\n]/)
      .map(&:strip)
      .reject(&:blank?)
      .map { |n| n.to_i }
      .select { |n| n >= 0 && n <= 9999 } # Supporta da 0 a 9999
  end
end
