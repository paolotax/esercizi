module Searchable
  extend ActiveSupport::Concern

  included do
    after_create_commit :create_in_search_index
    after_update_commit :update_in_search_index
    after_destroy_commit :remove_from_search_index
  end

  def create_in_search_index
    Search::Record.upsert!(self, search_record_attributes)
  end

  def update_in_search_index
    Search::Record.upsert!(self, search_record_attributes)
  end

  def remove_from_search_index
    Search::Record.remove!(self)
  end

  # Override in model
  def search_record_attributes
    raise NotImplementedError
  end
end
