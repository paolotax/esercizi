class Strumenti::AbacoController < ApplicationController
  def show
    # Mostra solo il form e l'abaco libero
  end

  def generate
    @numbers = params[:numbers] || ""
    @abachi = Abaco.parse_multiple(@numbers) if @numbers.present?

    render :show
  end

  def examples
    # View con esempi di utilizzo dell'abaco
  end
end
