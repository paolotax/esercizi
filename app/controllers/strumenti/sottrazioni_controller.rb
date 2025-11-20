class Strumenti::SottrazioniController < ApplicationController
  def show
    # Mostra solo il form
  end

  def generate
    @operations = params[:operations] || ""
    show_minuend_subtrahend = params[:show_minuend_subtrahend] == "true"

    if @operations.present?
      @sottrazioni = Sottrazione.parse_multiple(@operations).map do |sottrazione|
        # Ricrea la sottrazione con le opzioni di visualizzazione
        Sottrazione.new(
          minuend: sottrazione.minuend,
          subtrahend: sottrazione.subtrahend,
          show_minuend_subtrahend: show_minuend_subtrahend,
          show_toolbar: true,
          show_borrow: true
        )
      end
    end

    render :show
  end
end
