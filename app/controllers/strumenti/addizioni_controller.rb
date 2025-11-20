class Strumenti::AddizioniController < ApplicationController
  def show
    # Mostra solo il form
  end

  def generate
    @operations = params[:operations] || ""
    show_addends = params[:show_addends] == "true"

    if @operations.present?
      @addizioni = Addizione.parse_multiple(@operations).map do |addizione|
        # Ricrea l'addizione con le opzioni di visualizzazione
        Addizione.new(
          addends: addizione.addends,
          operator: addizione.operator,
          show_addends: show_addends,
          show_toolbar: true,
          show_carry: true
        )
      end
    end

    render :show
  end
end
