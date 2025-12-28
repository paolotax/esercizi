# frozen_string_literal: true

# Normalizza opzioni generiche in opzioni specifiche per ogni tipo di operazione
#
# Opzioni generiche supportate:
#   - show_operands → mostra operandi (addendi, minuendo/sottraendo, etc.)
#   - show_solution → mostra risultato
#   - show_toolbar  → barra strumenti
#   - show_labels   → etichette (u, da, h, k)
#   - show_carry    → riporti/prestiti
#   - show_steps    → passaggi intermedi
#   - layout        → quaderno/column (mappa a grid_style)
#
module GenericOptions
  extend ActiveSupport::Concern

  # Mapping delle opzioni generiche per ogni tipo
  MAPPINGS = {
    "Addizione" => {
      show_operands: :show_addends,
      show_carry: :show_carry,
      layout: :grid_style
    },
    "Sottrazione" => {
      show_operands: :show_minuend_subtrahend,
      show_carry: :show_borrow,
      layout: :grid_style
    },
    "Moltiplicazione" => {
      show_operands: :show_multiplicand_multiplier,
      show_carry: :show_carry,
      show_steps: :show_partial_products,
      layout: :grid_style
    },
    "Divisione" => {
      show_operands: :show_dividend_divisor,
      show_steps: :show_steps,
      layout: :grid_style
    }
  }.freeze

  # Opzioni che passano direttamente senza mapping
  PASSTHROUGH = %i[show_solution show_toolbar show_labels title].freeze

  class_methods do
    # Normalizza opzioni generiche in specifiche per questo tipo
    def normalize_options(options)
      return {} if options.blank?

      result = {}
      mapping = MAPPINGS[name] || {}

      options.each do |key, value|
        key_sym = key.to_sym

        if mapping.key?(key_sym)
          # Mappa opzione generica a specifica
          result[mapping[key_sym]] = value
        elsif PASSTHROUGH.include?(key_sym)
          # Passa direttamente
          result[key_sym] = value
        else
          # Opzione già specifica, passa come è
          result[key_sym] = value
        end
      end

      result
    end
  end

  # Normalizza opzioni prima di assegnarle a data
  def assign_generic_options(options)
    normalized = self.class.normalize_options(options)
    normalized.each do |key, value|
      self.send("#{key}=", value) if respond_to?("#{key}=")
    end
  end
end
