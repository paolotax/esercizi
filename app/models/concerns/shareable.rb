module Shareable
  extend ActiveSupport::Concern

  included do
    # Callbacks e validazioni comuni per modelli condivisibili
    before_create :ensure_share_token
    validates :share_token, uniqueness: true, allow_nil: true
  end

  # Metodi di istanza
  def shareable_url
    return nil unless share_token.present?
    Rails.application.routes.url_helpers.public_esercizio_url(share_token: share_token)
  end

  def shareable_path
    return nil unless share_token.present?
    Rails.application.routes.url_helpers.public_esercizio_path(share_token: share_token)
  end

  def regenerate_share_token!
    generate_unique_share_token
    save
  end

  def has_share_token?
    share_token.present?
  end

  private

  def ensure_share_token
    generate_unique_share_token if share_token.blank?
  end

  def generate_unique_share_token
    loop do
      self.share_token = SecureRandom.urlsafe_base64(8)
      break unless self.class.exists?(share_token: share_token)
    end
  end

  class_methods do
    def find_by_share_token(token)
      find_by(share_token: token)
    end

    def find_by_share_token!(token)
      find_by!(share_token: token)
    end
  end
end