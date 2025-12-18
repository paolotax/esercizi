require "nokogiri"

namespace :search do
  desc "Rebuild search index for all pages"
  task rebuild: :environment do
    puts "Pulizia indice esistente..."
    Search::Record.delete_all
    ActiveRecord::Base.connection.execute("DELETE FROM search_records_fts")

    print "Indicizzando pagine"
    indexed_pages = 0
    Pagina.find_each do |pagina|
      html_content = extract_html_content(pagina)
      attributes = pagina.search_record_attributes
      # Usa solo il contenuto HTML come content (include gia i metadati)
      attributes[:content] = html_content if html_content.present?

      Search::Record.upsert!(pagina, attributes)
      print "."
      indexed_pages += 1
    end
    puts " #{indexed_pages} pagine indicizzate"

    puts "Completato!"
  end

  def extract_html_content(pagina)
    # Estrai il codice base dal view_template (es. "nvl5_gram_p001" -> "nvl5_gram")
    return nil unless pagina.view_template.present?

    base_code = pagina.view_template.sub(/_p\d+$/, "")
    numero_padded = pagina.numero.to_s.rjust(3, "0")
    asset_dir = Rails.root.join("app", "assets", "images", base_code, "p#{numero_padded}")

    return nil unless asset_dir.exist?

    # Trova il file HTML con timestamp piu alto
    html_files = Dir.glob(asset_dir.join("17*.html"))
    return nil if html_files.empty?

    # Ordina per timestamp (parte numerica del nome file) e prendi il piu recente
    latest_html = html_files.max_by do |f|
      File.basename(f).gsub(/\D/, "").to_i
    end

    return nil unless latest_html

    # Estrai il testo dall'HTML (senza tag)
    html = File.read(latest_html)
    doc = Nokogiri::HTML(html)
    text = doc.text.gsub(/\s+/, " ").strip

    # Aggiungi i metadati contestuali
    metadata = build_metadata(pagina)

    [text, metadata].compact.join(" ")
  rescue => e
    Rails.logger.warn "Errore estrazione HTML per pagina #{pagina.id}: #{e.message}"
    nil
  end

  def build_metadata(pagina)
    parts = [
      pagina.sottotitolo,
      "Pagina #{pagina.numero}",
      pagina.disciplina&.nome,
      pagina.disciplina&.volume&.nome,
      pagina.disciplina&.volume&.corso&.nome,
      pagina.disciplina&.volume&.classe ? "Classe #{pagina.disciplina.volume.classe}" : nil
    ]
    parts.compact.join(" ")
  end
end
