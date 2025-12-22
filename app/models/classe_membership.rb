class ClasseMembership < ApplicationRecord
  belongs_to :classe
  belongs_to :user

  validates :user_id, uniqueness: { scope: :classe_id }
end
