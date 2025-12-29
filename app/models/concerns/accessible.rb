# frozen_string_literal: true

module Accessible
  extend ActiveSupport::Concern

  included do
    has_many :shares, as: :shareable, dependent: :destroy
  end

  def shared_with?(user)
    shares.active.exists?(recipient: user) ||
      shares.active.exists?(recipient: user.account)
  end
end
