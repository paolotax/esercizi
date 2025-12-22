class Session < ApplicationRecord
  belongs_to :identity

  def signed_id
    super(purpose: :session_token)
  end

  def self.find_signed(token)
    find_signed!(token, purpose: :session_token)
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    nil
  end
end
