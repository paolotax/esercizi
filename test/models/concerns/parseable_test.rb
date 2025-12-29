# frozen_string_literal: true

require "test_helper"

class ParseableTest < ActiveSupport::TestCase
  setup do
    # Forza il caricamento di tutti i model Parseable
    # (Rails li carica lazily, quindi dobbiamo referenziarli)
    [Addizione, Sottrazione, Moltiplicazione, Divisione]
  end

  test "registers types automatically when included" do
    types = Parseable.registered_types

    assert_includes types, Addizione
    assert_includes types, Sottrazione
    assert_includes types, Moltiplicazione
    assert_includes types, Divisione
  end

  test "registered_types contains at least 4 operation types" do
    assert_operator Parseable.registered_types.size, :>=, 4
  end
end
