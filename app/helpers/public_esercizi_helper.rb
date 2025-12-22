module PublicEserciziHelper
  def render_operation_display(operation)
    config = operation["config"] || {}

    case operation["type"]
    when "addizione"
      if config["operation_text"].present?
        config["operation_text"]
      elsif config["values"].present?
        config["values"].join(" + ")
      else
        "Addizione"
      end
    when "sottrazione"
      if config["operation_text"].present?
        config["operation_text"]
      elsif config["values"].present?
        config["values"].join(" - ")
      else
        "Sottrazione"
      end
    when "moltiplicazione"
      if config["operation_text"].present?
        config["operation_text"]
      elsif config["multiplicand"].present? && config["multiplier"].present?
        "#{config['multiplicand']} × #{config['multiplier']}"
      else
        "Moltiplicazione"
      end
    when "abaco"
      if config["value"].present?
        "Rappresenta il numero #{config['value']}"
      elsif config["correct_value"].present?
        "Rappresenta il numero #{config['correct_value']}"
      else
        "Abaco"
      end
    else
      operation["type"].capitalize
    end
  end
end
