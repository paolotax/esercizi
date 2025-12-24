# frozen_string_literal: true

class Question < ApplicationRecord
  belongs_to :esercizio
  belongs_to :account, optional: true
  belongs_to :creator, class_name: "User", optional: true

  delegated_type :questionable, types: %w[Addizione Sottrazione Moltiplicazione Divisione Abaco]

  scope :ordered, -> { order(:position) }
end
