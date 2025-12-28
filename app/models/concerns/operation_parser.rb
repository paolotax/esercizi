# frozen_string_literal: true

module OperationParser
  extend self

  # Parse multiple operations from text
  # Input: "123+45\n67-23\n12x4\n144/12"
  # Output: [{ type: "Addizione", data: { addends: ["123", "45"] } }, ...]
  def parse_all(text)
    return [] if text.blank?

    text
      .split(/[;\n,]/)
      .map(&:strip)
      .reject(&:blank?)
      .filter_map { |line| parse_line(line) }
  end

  private

  def parse_line(line)
    # Remove all spaces
    cleaned = line.gsub(/\s+/, "")

    # Detect operator and parse accordingly
    case cleaned
    when /[+]/
      parse_addition(cleaned)
    when /[-]/
      parse_subtraction(cleaned)
    when /[x*×]/i
      parse_multiplication(cleaned)
    when /[\/÷:]/
      parse_division(cleaned)
    end
  end

  def parse_addition(line)
    parts = line.split("+").map(&:strip).reject(&:blank?)
    return nil if parts.size < 2
    return nil unless parts.all? { |p| valid_number?(p) }

    { type: "Addizione", data: { addends: parts } }
  end

  def parse_subtraction(line)
    parts = line.split("-").map(&:strip).reject(&:blank?)
    return nil if parts.size != 2
    return nil unless parts.all? { |p| valid_number?(p) }

    { type: "Sottrazione", data: { minuend: parts[0], subtrahend: parts[1] } }
  end

  def parse_multiplication(line)
    parts = line.split(/[x*×]/i).map(&:strip).reject(&:blank?)
    return nil if parts.size != 2
    return nil unless parts.all? { |p| valid_number?(p) }

    { type: "Moltiplicazione", data: { multiplicand: parts[0], multiplier: parts[1] } }
  end

  def parse_division(line)
    parts = line.split(/[\/÷:]/).map(&:strip).reject(&:blank?)
    return nil if parts.size != 2
    return nil unless parts.all? { |p| valid_number?(p) }

    { type: "Divisione", data: { dividend: parts[0], divisor: parts[1] } }
  end

  def valid_number?(str)
    str.match?(/^\d+([.,]\d+)?$/)
  end
end
