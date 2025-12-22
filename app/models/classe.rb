class Classe < ApplicationRecord
  belongs_to :account
  belongs_to :teacher, class_name: "User"

  has_many :memberships, class_name: "ClasseMembership", dependent: :destroy
  has_many :students, through: :memberships, source: :user

  validates :name, presence: true
  validates :name, uniqueness: { scope: [:account_id, :anno_scolastico] }

  scope :current_year, -> { where(anno_scolastico: current_anno_scolastico) }

  def self.current_anno_scolastico
    today = Date.current
    year = today.month >= 9 ? today.year : today.year - 1
    "#{year}/#{year + 1}"
  end

  def add_student(user)
    students << user unless students.include?(user)
  end

  def remove_student(user)
    students.delete(user)
  end
end
