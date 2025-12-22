class EsercizioAttempt < ApplicationRecord
  # Serializzazione JSON per SQLite
  serialize :results, coder: JSON, type: Hash

  # Associazioni
  belongs_to :account, optional: true
  belongs_to :esercizio
  belongs_to :user, optional: true

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

  def complete!(results_data = {}, score_value = nil, time_spent_value = nil)
    return false if completed?

    self.completed_at = Time.current
    self.results = results_data
    self.score = score_value || calculate_score(results_data)

    # Usa il tempo passato dal frontend se disponibile, altrimenti calcola dalla differenza
    if time_spent_value.present?
      self.time_spent = time_spent_value.to_i
    elsif started_at
      self.time_spent = (completed_at - started_at).to_i
    end

    save
  end

  def duration
    # Preferisci time_spent se disponibile, altrimenti calcola dalla differenza
    return time_spent if time_spent.present?
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

    total_seconds = duration
    hours = total_seconds / 3600
    minutes = (total_seconds % 3600) / 60
    seconds = total_seconds % 60

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

  def student_display_name
    # Restituisce il nome dell'utente se presente, altrimenti dal results o identifier
    if user.present?
      user.name
    elsif results.is_a?(Hash) && results['student_name'].present?
      results['student_name']
    else
      student_identifier
    end
  end

  def anonymous?
    user_id.nil?
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
