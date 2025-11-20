# frozen_string_literal: true

module Strumenti
  class MoltiplicazioniController < ApplicationController
    def show
      @multiplications = []
    end

    def generate
      @multiplications_string = params[:multiplications]
      @multiplications = Moltiplicazione.parse_multiple(@multiplications_string)

      render :show
    end

    def examples
      # Pagina con esempi di utilizzo
    end
  end
end
