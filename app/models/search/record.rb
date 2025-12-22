class Search::Record < ApplicationRecord
  self.table_name = "search_records"

  belongs_to :searchable, polymorphic: true
  belongs_to :pagina, optional: true
  belongs_to :disciplina, optional: true
  belongs_to :volume, optional: true

  class << self
    def upsert!(searchable, attributes)
      record = find_or_initialize_by(
        searchable_type: searchable.class.name,
        searchable_id: searchable.id
      )
      record.update!(attributes)
      sync_fts(record)
      record
    end

    def remove!(searchable)
      record = find_by(
        searchable_type: searchable.class.name,
        searchable_id: searchable.id
      )
      return unless record

      remove_from_fts(record.id)
      record.destroy!
    end

    def search(query)
      return none if query.blank?

      sanitized = sanitize_query(query)
      return none if sanitized.blank?

      joins("INNER JOIN search_records_fts ON search_records_fts.rowid = search_records.id")
        .where("search_records_fts MATCH ?", sanitized)
        .select(
          "search_records.*",
          "highlight(search_records_fts, 0, '<mark>', '</mark>') AS highlighted_title",
          "snippet(search_records_fts, 1, '<mark>', '</mark>', '...', 20) AS highlighted_content"
        )
        .order(Arel.sql("rank"))
    end

    private

    def sync_fts(record)
      connection.execute(<<-SQL)
        INSERT OR REPLACE INTO search_records_fts(rowid, title, content)
        VALUES (#{record.id}, #{connection.quote(record.title)}, #{connection.quote(record.content)})
      SQL
    end

    def remove_from_fts(id)
      connection.execute(sanitize_sql_array([ "DELETE FROM search_records_fts WHERE rowid = ?", id.to_i ]))
    end

    def sanitize_query(query)
      query.to_s.gsub(/[^\w\s"]/, " ").squish
    end
  end
end
