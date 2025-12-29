# frozen_string_literal: true

require "test_helper"

class AddizioneTest < ActiveSupport::TestCase
  # DSL Parseable
  test "operator_regex matches plus sign" do
    assert_equal(/[+]/, Addizione.operator_regex)
  end

  test "field_names is addends" do
    assert_equal [:addends], Addizione.field_names
  end

  # parse con 2 addendi
  test "parse with two addends returns hash" do
    result = Addizione.parse("12+34")
    assert_equal({ addends: ["12", "34"] }, result)
  end

  # parse con N addendi
  test "parse with three addends returns array" do
    result = Addizione.parse("12+34+56")
    assert_equal({ addends: ["12", "34", "56"] }, result)
  end

  test "parse with four addends returns array" do
    result = Addizione.parse("1+2+3+4")
    assert_equal({ addends: ["1", "2", "3", "4"] }, result)
  end

  # parse con spazi
  test "parse ignores spaces" do
    result = Addizione.parse("12 + 34")
    assert_equal({ addends: ["12", "34"] }, result)
  end

  # parse con numeri decimali
  test "parse converts comma to dot in decimals" do
    result = Addizione.parse("12,5+34,7")
    assert_equal({ addends: ["12.5", "34.7"] }, result)
  end

  test "parse handles dot decimals" do
    result = Addizione.parse("12.5+34.7")
    assert_equal({ addends: ["12.5", "34.7"] }, result)
  end

  # parse con input invalido
  test "parse with empty string returns nil" do
    assert_nil Addizione.parse("")
  end

  test "parse with nil returns nil" do
    assert_nil Addizione.parse(nil)
  end

  test "parse with no operator returns nil" do
    assert_nil Addizione.parse("1234")
  end

  test "parse with letters returns nil" do
    assert_nil Addizione.parse("abc+def")
  end

  test "parse with subtraction operator returns nil" do
    assert_nil Addizione.parse("12-34")
  end

  # parse_multiple
  test "parse_multiple splits by semicolon" do
    result = Addizione.parse_multiple("12+34;56+78")
    assert_equal 2, result.size
    assert_equal({ addends: ["12", "34"] }, result[0])
    assert_equal({ addends: ["56", "78"] }, result[1])
  end

  test "parse_multiple splits by newline" do
    result = Addizione.parse_multiple("12+34\n56+78")
    assert_equal 2, result.size
  end

  test "parse_multiple splits by comma" do
    result = Addizione.parse_multiple("12+34,56+78")
    assert_equal 2, result.size
  end

  test "parse_multiple ignores invalid lines" do
    result = Addizione.parse_multiple("12+34;invalid;56+78")
    assert_equal 2, result.size
  end

  test "parse_multiple with empty string returns empty array" do
    assert_equal [], Addizione.parse_multiple("")
  end

  # build_renderer
  test "build_renderer returns Addizione::Renderer" do
    renderer = Addizione.build_renderer("12+34")
    assert_instance_of Addizione::Renderer, renderer
  end

  test "build_renderer with invalid input returns nil" do
    assert_nil Addizione.build_renderer("invalid")
  end

  test "build_renderer passes options to renderer" do
    renderer = Addizione.build_renderer("12+34", show_carry: true)
    assert_not_nil renderer
  end

  # build_renderers
  test "build_renderers returns array of renderers" do
    renderers = Addizione.build_renderers("12+34;56+78")
    assert_equal 2, renderers.size
    assert renderers.all? { |r| r.is_a?(Addizione::Renderer) }
  end

  test "build_renderers with empty string returns empty array" do
    assert_equal [], Addizione.build_renderers("")
  end

  # from_string
  test "from_string creates database record" do
    record = Addizione.from_string("12+34")
    assert_not_nil record
    assert record.persisted?
    assert_equal ["12", "34"], record.addends
  end

  test "from_string with invalid input returns nil" do
    assert_nil Addizione.from_string("invalid")
  end

  # from_strings
  test "from_strings creates multiple records" do
    records = Addizione.from_strings("12+34;56+78")
    assert_equal 2, records.size
    assert records.all?(&:persisted?)
  end

  # to_renderer
  test "to_renderer converts record to renderer" do
    record = Addizione.create!(data: { addends: ["12", "34"] })
    renderer = record.to_renderer
    assert_instance_of Addizione::Renderer, renderer
  end
end
