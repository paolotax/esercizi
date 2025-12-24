# frozen_string_literal: true

class Sottrazione < ApplicationRecord
  include Questionable

  self.table_name = "sottrazioni"

  # Factory: crea un Renderer da stringa operazione
  def self.build_renderer(operation_string, **options)
    parsed = Renderer.parse(operation_string)
    return nil unless parsed

    Renderer.new(minuend: parsed.minuend, subtrahend: parsed.subtrahend, **options)
  end

  # Factory: crea più Renderer da stringhe separate da ; o \n
  def self.build_renderers(operations_string, **options)
    Renderer.parse_multiple(operations_string).filter_map do |parsed|
      Renderer.new(minuend: parsed.minuend, subtrahend: parsed.subtrahend, **options)
    end
  end

  # Istanza: converte record DB in Renderer
  def to_renderer
    Renderer.new(**data.symbolize_keys)
  end
end
