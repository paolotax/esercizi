module User::Role
  extend ActiveSupport::Concern

  included do
    enum :role, %i[owner teacher student].index_by(&:itself), scopes: false

    scope :owners, -> { where(active: true, role: :owner) }
    scope :teachers, -> { where(active: true, role: [:owner, :teacher]) }
    scope :students, -> { where(active: true, role: :student) }
  end

  def teacher?
    super || owner?
  end

  def at_least_teacher?
    teacher? || owner?
  end

  def can_change?(other)
    (owner? && !other.owner?) || other == self
  end

  def can_administer?(other)
    owner? && !other.owner? && other != self
  end

  def can_manage_users?
    owner?
  end

  def can_manage_esercizi?
    at_least_teacher?
  end

  def can_create_classi?
    at_least_teacher?
  end

  def can_view_all_attempts?
    at_least_teacher?
  end

  def can_administer_esercizio?(esercizio)
    owner? || esercizio.creator == self
  end
end
