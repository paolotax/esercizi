# frozen_string_literal: true

require "test_helper"

class MoltiplicazioneTest < ActiveSupport::TestCase
  # DSL Parseable
  test "operator_regex matches x, *, and multiplication sign" do
    assert Moltiplicazione.operator_regex.match?("x")
    assert Moltiplicazione.operator_regex.match?("X")
    assert Moltiplicazione.operator_regex.match?("*")
    assert Moltiplicazione.operator_regex.match?("\u00D7") # ×
  end

  test "field_names are multiplicand and multiplier" do
    assert_equal [:multiplicand, :multiplier], Moltiplicazione.field_names
  end

  # parse con x
  test "parse with lowercase x returns hash" do
    result = Moltiplicazione.parse("12x3")
    assert_equal({ multiplicand: "12", multiplier: "3" }, result)
  end

  test "parse with uppercase X returns hash" do
    result = Moltiplicazione.parse("12X3")
    assert_equal({ multiplicand: "12", multiplier: "3" }, result)
  end

  # parse con *
  test "parse with asterisk returns hash" do
    result = Moltiplicazione.parse("12*3")
    assert_equal({ multiplicand: "12", multiplier: "3" }, result)
  end

  # parse con ×
  test "parse with multiplication sign returns hash" do
    result = Moltiplicazione.parse("12\u00D73")
    assert_equal({ multiplicand: "12", multiplier: "3" }, result)
  end

  # parse con spazi
  test "parse ignores spaces" do
    result = Moltiplicazione.parse("12 x 3")
    assert_equal({ multiplicand: "12", multiplier: "3" }, result)
  end

  # parse con decimali
  test "parse converts comma to dot in decimals" do
    result = Moltiplicazione.parse("12,5x3,2")
    assert_equal({ multiplicand: "12.5", multiplier: "3.2" }, result)
  end

  # parse con input invalido
  test "parse with empty string returns nil" do
    assert_nil Moltiplicazione.parse("")
  end

  test "parse with nil returns nil" do
    assert_nil Moltiplicazione.parse(nil)
  end

  test "parse with no operator returns nil" do
    assert_nil Moltiplicazione.parse("1234")
  end

  test "parse with addition operator returns nil" do
    assert_nil Moltiplicazione.parse("12+3")
  end

  # parse_multiple
  test "parse_multiple splits by semicolon" do
    result = Moltiplicazione.parse_multiple("12x3;45x6")
    assert_equal 2, result.size
    assert_equal({ multiplicand: "12", multiplier: "3" }, result[0])
    assert_equal({ multiplicand: "45", multiplier: "6" }, result[1])
  end

  test "parse_multiple ignores invalid lines" do
    result = Moltiplicazione.parse_multiple("12x3;invalid;45x6")
    assert_equal 2, result.size
  end

  test "parse_multiple with empty string returns empty array" do
    assert_equal [], Moltiplicazione.parse_multiple("")
  end

  # build_renderer
  test "build_renderer returns Moltiplicazione::Renderer" do
    renderer = Moltiplicazione.build_renderer("12x3")
    assert_instance_of Moltiplicazione::Renderer, renderer
  end

  test "build_renderer with invalid input returns nil" do
    assert_nil Moltiplicazione.build_renderer("invalid")
  end

  # build_renderers
  test "build_renderers returns array of renderers" do
    renderers = Moltiplicazione.build_renderers("12x3;45x6")
    assert_equal 2, renderers.size
    assert renderers.all? { |r| r.is_a?(Moltiplicazione::Renderer) }
  end

  # from_string
  test "from_string creates database record" do
    record = Moltiplicazione.from_string("12x3")
    assert_not_nil record
    assert record.persisted?
    assert_equal "12", record.multiplicand
    assert_equal "3", record.multiplier
  end

  # from_strings
  test "from_strings creates multiple records" do
    records = Moltiplicazione.from_strings("12x3;45x6")
    assert_equal 2, records.size
    assert records.all?(&:persisted?)
  end

  # to_renderer
  test "to_renderer converts record to renderer" do
    record = Moltiplicazione.create!(data: { multiplicand: "12", multiplier: "3" })
    renderer = record.to_renderer
    assert_instance_of Moltiplicazione::Renderer, renderer
  end
end
