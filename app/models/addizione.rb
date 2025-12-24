# frozen_string_literal: true

class Addizione < ApplicationRecord
  include Questionable

  # Specifica il nome della tabella (plurale italiano)
  self.table_name = "addizioni"

  def to_renderer
    Addizione::Renderer.new(**data.symbolize_keys)
  end
end
