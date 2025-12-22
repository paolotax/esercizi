class Account::JoinCode < ApplicationRecord
  self.table_name = "account_join_codes"

  CODE_LENGTH = 12

  belongs_to :account

  enum :role, %i[student teacher].index_by(&:itself), default: :student

  scope :active, -> { where("usage_count < usage_limit") }

  before_create :generate_code, if: -> { code.blank? }

  validates :code, uniqueness: true, allow_nil: true

  def redeem_if(&block)
    with_lock do
      if active? && block.call(account, role)
        increment!(:usage_count)
        true
      else
        false
      end
    end
  end

  def active?
    usage_count < usage_limit
  end

  def reset!
    generate_code
    self.usage_count = 0
    save!
  end

  def formatted_code
    code
  end

  private
    def generate_code
      self.code = loop do
        candidate = SecureRandom.base58(CODE_LENGTH).scan(/.{4}/).join("-")
        break candidate unless self.class.exists?(code: candidate)
      end
    end
end
