class Strumenti::AddizioniController < ApplicationController
  def show
    @operations = params[:operations] || ""
    @operations_array = parse_operations(@operations) if @operations.present?
  end

  private

  def parse_operations(operations_string)
    # Supporta più formati:
    # - Una operazione per riga: "234 + 1234\n45 + 67"
    # - Operazioni separate da virgola: "234 + 1234, 45 + 67"
    # - Operazioni separate da punto e virgola: "234 + 1234; 45 + 67"

    operations_string
      .split(/[,;\n]/)
      .map(&:strip)
      .reject(&:blank?)
      .map { |op| op.strip }
  end
end
