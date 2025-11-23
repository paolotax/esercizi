class EsercizioAttempt < ApplicationRecord
  # Serializzazione JSON per SQLite
  serialize :results, coder: JSON, type: Hash

  # Associazioni
  belongs_to :esercizio

  # Validazioni
  validates :student_identifier, presence: true
  validates :started_at, presence: true

  # Callbacks
  before_validation :set_started_at, on: :create

  # Scopes
  scope :completed, -> { where.not(completed_at: nil) }
  scope :incomplete, -> { where(completed_at: nil) }
  scope :by_student, ->(student_id) { where(student_identifier: student_id) }
  scope :recent, -> { order(created_at: :desc) }

  # Metodi pubblici
  def completed?
    completed_at.present?
  end

  def incomplete?
    !completed?
  end

  def complete!(results_data = {}, score_value = nil)
    return false if completed?

    self.completed_at = Time.current
    self.results = results_data
    self.score = score_value || calculate_score(results_data)
    self.time_spent = (completed_at - started_at).to_i if started_at
    save
  end

  def duration
    return nil unless started_at

    end_time = completed_at || Time.current
    (end_time - started_at).to_i
  end

  def duration_in_minutes
    return nil unless duration
    (duration / 60.0).round(1)
  end

  def formatted_duration
    return nil unless duration

    hours = duration / 3600
    minutes = (duration % 3600) / 60
    seconds = duration % 60

    if hours > 0
      format('%d:%02d:%02d', hours, minutes, seconds)
    else
      format('%d:%02d', minutes, seconds)
    end
  end

  def success_rate
    return 0 unless results.present? && results['operations'].present?

    total = results['operations'].count
    correct = results['operations'].count { |op| op['correct'] == true }

    return 0 if total == 0
    ((correct.to_f / total) * 100).round(1)
  end

  private

  def set_started_at
    self.started_at ||= Time.current
  end

  def calculate_score(results_data)
    return 0 unless results_data['operations'].present?

    total = results_data['operations'].count
    correct = results_data['operations'].count { |op| op['correct'] == true }

    return 0 if total == 0
    ((correct.to_f / total) * 100).round(2)
  end
end
