# frozen_string_literal: true

require "test_helper"

class SottrazioneTest < ActiveSupport::TestCase
  # DSL Parseable
  test "operator_regex matches minus sign" do
    assert_equal(/[-]/, Sottrazione.operator_regex)
  end

  test "field_names are minuend and subtrahend" do
    assert_equal [ :minuend, :subtrahend ], Sottrazione.field_names
  end

  # parse valido
  test "parse with valid subtraction returns hash" do
    result = Sottrazione.parse("100-50")
    assert_equal({ minuend: "100", subtrahend: "50" }, result)
  end

  test "parse ignores spaces" do
    result = Sottrazione.parse("100 - 50")
    assert_equal({ minuend: "100", subtrahend: "50" }, result)
  end

  # parse con decimali
  test "parse converts comma to dot in decimals" do
    result = Sottrazione.parse("10,5-3,2")
    assert_equal({ minuend: "10.5", subtrahend: "3.2" }, result)
  end

  # parse con risultato negativo (valid_operation?)
  test "parse with negative result returns nil" do
    assert_nil Sottrazione.parse("50-100")
  end

  test "parse with equal values returns valid result" do
    result = Sottrazione.parse("50-50")
    assert_equal({ minuend: "50", subtrahend: "50" }, result)
  end

  # parse con input invalido
  test "parse with empty string returns nil" do
    assert_nil Sottrazione.parse("")
  end

  test "parse with nil returns nil" do
    assert_nil Sottrazione.parse(nil)
  end

  test "parse with no operator returns nil" do
    assert_nil Sottrazione.parse("1234")
  end

  test "parse with addition operator returns nil" do
    assert_nil Sottrazione.parse("12+34")
  end

  # parse_multiple
  test "parse_multiple splits by semicolon" do
    result = Sottrazione.parse_multiple("100-50;200-75")
    assert_equal 2, result.size
    assert_equal({ minuend: "100", subtrahend: "50" }, result[0])
    assert_equal({ minuend: "200", subtrahend: "75" }, result[1])
  end

  test "parse_multiple ignores negative results" do
    result = Sottrazione.parse_multiple("100-50;50-100;200-75")
    assert_equal 2, result.size
  end

  test "parse_multiple with empty string returns empty array" do
    assert_equal [], Sottrazione.parse_multiple("")
  end

  # build_renderer
  test "build_renderer returns Sottrazione::Renderer" do
    renderer = Sottrazione.build_renderer("100-50")
    assert_instance_of Sottrazione::Renderer, renderer
  end

  test "build_renderer with negative result returns nil" do
    assert_nil Sottrazione.build_renderer("50-100")
  end

  test "build_renderer with invalid input returns nil" do
    assert_nil Sottrazione.build_renderer("invalid")
  end

  # build_renderers
  test "build_renderers returns array of renderers" do
    renderers = Sottrazione.build_renderers("100-50;200-75")
    assert_equal 2, renderers.size
    assert renderers.all? { |r| r.is_a?(Sottrazione::Renderer) }
  end

  # from_string
  test "from_string creates database record" do
    record = Sottrazione.from_string("100-50")
    assert_not_nil record
    assert record.persisted?
    assert_equal "100", record.minuend
    assert_equal "50", record.subtrahend
  end

  test "from_string with negative result returns nil" do
    assert_nil Sottrazione.from_string("50-100")
  end

  # from_strings
  test "from_strings creates multiple records" do
    records = Sottrazione.from_strings("100-50;200-75")
    assert_equal 2, records.size
    assert records.all?(&:persisted?)
  end

  test "from_strings skips negative results" do
    records = Sottrazione.from_strings("100-50;50-100;200-75")
    assert_equal 2, records.size
  end

  # to_renderer
  test "to_renderer converts record to renderer" do
    record = Sottrazione.create!(data: { minuend: "100", subtrahend: "50" })
    renderer = record.to_renderer
    assert_instance_of Sottrazione::Renderer, renderer
  end
end
