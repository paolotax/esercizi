# frozen_string_literal: true

class Sottrazione < ApplicationRecord
  include Questionable

  # Specifica il nome della tabella (plurale italiano)
  self.table_name = "sottrazioni"

  def to_renderer
    Sottrazione::Renderer.new(**data.symbolize_keys)
  end
end
