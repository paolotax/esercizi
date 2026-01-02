class Account < ApplicationRecord
  has_one :join_code

  has_many :users, dependent: :destroy
  has_many :corsi, dependent: :destroy
  has_many :volumi, dependent: :destroy
  has_many :discipline, dependent: :destroy
  has_many :pagine, dependent: :destroy
  has_many :esercizi, dependent: :destroy
  has_many :esercizio_attempts, dependent: :destroy
  has_many :classi, dependent: :destroy

  before_create :assign_external_account_id
  after_create :create_join_codes

  validates :name, presence: true

  class << self
    def create_with_owner(account:, owner:)
      create!(**account).tap do |account|
        account.users.create!(**owner.reverse_merge(role: "owner", verified_at: Time.current))
      end
    end

    def accepting_signups?
      true
    end
  end

  def slug
    "/#{AccountSlug.encode(external_account_id)}"
  end

  def account
    self
  end

  private
    def assign_external_account_id
      self.external_account_id ||= generate_external_id
    end

    def generate_external_id
      (Account.maximum(:external_account_id) || 1000000) + 1
    end

    def create_join_codes
      Account::JoinCode.create!(account: self, role: "teacher")
      Account::JoinCode.create!(account: self, role: "student")
    end
end
