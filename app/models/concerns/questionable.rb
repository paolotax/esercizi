# frozen_string_literal: true

module Questionable
  extend ActiveSupport::Concern

  included do
    has_one :question, as: :questionable, touch: true, dependent: :destroy
    # Il campo data è già di tipo JSON nativo in SQLite, non serve serialize
  end

  def to_renderer
    raise NotImplementedError, "#{self.class} must implement #to_renderer"
  end
end
