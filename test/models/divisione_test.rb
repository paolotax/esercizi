# frozen_string_literal: true

require "test_helper"

class DivisioneTest < ActiveSupport::TestCase
  # DSL Parseable
  test "operator_regex matches slash, division sign, and colon" do
    assert Divisione.operator_regex.match?("/")
    assert Divisione.operator_regex.match?("\u00F7") # ÷
    assert Divisione.operator_regex.match?(":")
  end

  test "field_names are dividend and divisor" do
    assert_equal [:dividend, :divisor], Divisione.field_names
  end

  # parse con :
  test "parse with colon returns hash" do
    result = Divisione.parse("144:12")
    assert_equal({ dividend: "144", divisor: "12" }, result)
  end

  # parse con /
  test "parse with slash returns hash" do
    result = Divisione.parse("144/12")
    assert_equal({ dividend: "144", divisor: "12" }, result)
  end

  # parse con ÷
  test "parse with division sign returns hash" do
    result = Divisione.parse("144\u00F712")
    assert_equal({ dividend: "144", divisor: "12" }, result)
  end

  # parse con spazi
  test "parse ignores spaces" do
    result = Divisione.parse("144 : 12")
    assert_equal({ dividend: "144", divisor: "12" }, result)
  end

  # parse con decimali
  test "parse converts comma to dot in decimals" do
    result = Divisione.parse("14,4:1,2")
    assert_equal({ dividend: "14.4", divisor: "1.2" }, result)
  end

  # parse con divisore zero (valid_operation?)
  test "parse with zero divisor returns nil" do
    assert_nil Divisione.parse("144:0")
  end

  test "parse with zero divisor using slash returns nil" do
    assert_nil Divisione.parse("144/0")
  end

  # parse con input invalido
  test "parse with empty string returns nil" do
    assert_nil Divisione.parse("")
  end

  test "parse with nil returns nil" do
    assert_nil Divisione.parse(nil)
  end

  test "parse with no operator returns nil" do
    assert_nil Divisione.parse("1234")
  end

  test "parse with addition operator returns nil" do
    assert_nil Divisione.parse("12+3")
  end

  # parse_multiple
  test "parse_multiple splits by semicolon" do
    result = Divisione.parse_multiple("144:12;72:8")
    assert_equal 2, result.size
    assert_equal({ dividend: "144", divisor: "12" }, result[0])
    assert_equal({ dividend: "72", divisor: "8" }, result[1])
  end

  test "parse_multiple ignores zero divisor" do
    result = Divisione.parse_multiple("144:12;100:0;72:8")
    assert_equal 2, result.size
  end

  test "parse_multiple with empty string returns empty array" do
    assert_equal [], Divisione.parse_multiple("")
  end

  # build_renderer
  test "build_renderer returns Divisione::Renderer" do
    renderer = Divisione.build_renderer("144:12")
    assert_instance_of Divisione::Renderer, renderer
  end

  test "build_renderer with zero divisor returns nil" do
    assert_nil Divisione.build_renderer("144:0")
  end

  test "build_renderer with invalid input returns nil" do
    assert_nil Divisione.build_renderer("invalid")
  end

  # build_renderers
  test "build_renderers returns array of renderers" do
    renderers = Divisione.build_renderers("144:12;72:8")
    assert_equal 2, renderers.size
    assert renderers.all? { |r| r.is_a?(Divisione::Renderer) }
  end

  # from_string
  test "from_string creates database record" do
    record = Divisione.from_string("144:12")
    assert_not_nil record
    assert record.persisted?
    assert_equal "144", record.dividend
    assert_equal "12", record.divisor
  end

  test "from_string with zero divisor returns nil" do
    assert_nil Divisione.from_string("144:0")
  end

  # from_strings
  test "from_strings creates multiple records" do
    records = Divisione.from_strings("144:12;72:8")
    assert_equal 2, records.size
    assert records.all?(&:persisted?)
  end

  test "from_strings skips zero divisor" do
    records = Divisione.from_strings("144:12;100:0;72:8")
    assert_equal 2, records.size
  end

  # to_renderer
  test "to_renderer converts record to renderer" do
    record = Divisione.create!(data: { dividend: "144", divisor: "12" })
    renderer = record.to_renderer
    assert_instance_of Divisione::Renderer, renderer
  end
end
