class Strumenti::SottrazioniController < ApplicationController
  def show
    @operations = params[:operations] || ""
    @show_minuend_subtrahend = params[:show_minuend_subtrahend] == "true"
    @operations_array = parse_operations(@operations) if @operations.present?
  end

  private

  def parse_operations(operations_string)
    # Supporta più formati:
    # - Una operazione per riga: "487 - 258\n234 - 156"
    # - Operazioni separate da virgola: "487 - 258, 234 - 156"
    # - Operazioni separate da punto e virgola: "487 - 258; 234 - 156"

    operations_string
      .split(/[,;\n]/)
      .map(&:strip)
      .reject(&:blank?)
      .map { |op| op.strip }
  end
end
