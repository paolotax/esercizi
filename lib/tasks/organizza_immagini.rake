#!/usr/bin/env ruby
require "json"
require "nokogiri"
require "fileutils"

namespace :images do
  desc "Organizza immagini da libro EPUB in assets Rails"
  task :import, [ :book_id, :prefix, :mode ] => :environment do |t, args|
    importer = ImageImporter.new(
      book_id: args[:book_id],        # es: 'book_844'
      prefix: args[:prefix],           # es: 'nvl5_gram'
      source_dir: File.expand_path("~/Windows"),
      dest_dir: Rails.root.join("app/assets/images"),
      dry_run: args[:mode] == "dry_run"
    )
    importer.run
  end
end

class ImageImporter
  attr_reader :book_id, :prefix, :source_dir, :dest_dir, :dry_run

  def initialize(book_id:, prefix:, source_dir:, dest_dir:, dry_run: false)
    @book_id = book_id
    @prefix = prefix
    @source_dir = source_dir
    @dest_dir = dest_dir
    @dry_run = dry_run
    @stats = { processed: 0, skipped: 0, copied_files: 0, created_dirs: 0, errors: [] }
  end

  def run
    puts "=" * 60
    puts "IMPORT IMMAGINI: #{book_id} -> #{prefix}"
    puts dry_run ? "*** MODALITÀ DRY-RUN ***" : "*** MODALITÀ ESECUZIONE ***"
    puts "=" * 60

    # Verifica che le directory esistano
    unless Dir.exist?("#{source_dir}/#{book_id}")
      puts "ERRORE: Directory origine non trovata: #{source_dir}/#{book_id}"
      return
    end

    # 1. Carica mappatura da progressive_data.json
    mapping = load_page_mapping

    # 2. Trova il numero massimo di pagine
    html_dir = "#{source_dir}/#{book_id}/epub/html"
    all_html_files = Dir.glob("#{html_dir}/*.html")

    max_page = 0
    all_html_files.each do |f|
      if match = File.basename(f).match(/(\d{3})\.html$/)
        page_num = match[1].to_i
        max_page = page_num if page_num > max_page
      end
    end

    if max_page == 0
      puts "ERRORE: Nessun file HTML trovato in #{html_dir}"
      return
    end

    puts "\nProcessando #{max_page} pagine"
    puts "-" * 60

    # 3. Processa ogni pagina per numero
    (1..max_page).each do |page_num|
      process_page_by_number(page_num, mapping)
    end

    # 4. Report finale
    print_report
  end

  private

  def load_page_mapping
    json_path = "#{source_dir}/#{book_id}/xml/progressive_data.json"

    unless File.exist?(json_path)
      puts "WARNING: File progressive_data.json non trovato: #{json_path}"
      return {}
    end

    data = JSON.parse(File.read(json_path))

    mapping = {}
    data["capitoli"].each do |cap|
      cap["pagine"].each do |pag|
        page_num = pag["nome"]
        pag["risorse"].each do |risorsa|
          if risorsa[0].include?("/pages/") && risorsa[0].end_with?(".png")
            png_file = File.basename(risorsa[0])
            mapping[page_num] = png_file
          end
        end
      end
    end

    puts "Mappatura caricata: #{mapping.keys.length} pagine con PNG"
    mapping
  rescue JSON::ParserError => e
    puts "ERRORE parsing JSON: #{e.message}"
    {}
  end

  def process_page_by_number(page_num, mapping)
    page_str = page_num.to_s.rjust(3, "0")  # "056"

    # Crea la directory per questa pagina
    page_dir = "#{dest_dir}/#{prefix}/p#{page_str}"
    html_dir = "#{source_dir}/#{book_id}/epub/html"

    puts "\n--- Pagina #{page_num} (#{prefix}/p#{page_str}) ---"

    # Trova TUTTI gli HTML per questa pagina (qualsiasi timestamp)
    html_files = Dir.glob("#{html_dir}/*#{page_str}.html")

    # Se non ci sono HTML, controlla se c'è almeno il PNG
    if html_files.empty? && !mapping[page_num.to_s]
      puts "  [SKIP] Nessun contenuto per pagina #{page_num}"
      @stats[:skipped] += 1
      return
    end

    # Crea la directory per la pagina se necessario
    if dry_run
      unless Dir.exist?(page_dir)
        puts "  [DRY-RUN] Creazione directory: #{page_dir}"
        @stats[:created_dirs] += 1
      end
    else
      unless Dir.exist?(page_dir)
        FileUtils.mkdir_p(page_dir)
        puts "  [OK] Directory creata: #{page_dir}"
        @stats[:created_dirs] += 1
      end
    end

    # Copia TUTTI gli HTML trovati con i loro nomi originali
    html_files.each do |html_path|
      copy_html(html_path, page_dir)
    end

    # Parse il primo HTML per trovare le immagini (gli HTML dovrebbero avere le stesse immagini)
    images_to_copy = []
    if html_files.any?
      begin
        doc = Nokogiri::HTML(File.read(html_files.first))
        images = doc.css("img").map { |img| img["src"] }.compact
        images_to_copy = images.select { |src| src.include?("images/") }
                               .map { |src| File.basename(src) }
      rescue => e
        puts "  [ERROR] Errore parsing HTML: #{e.message}"
        @stats[:errors] << "#{html_files.first}: #{e.message}"
      end
    end

    # Copia PNG principale come page.png
    if mapping[page_num.to_s]
      copy_page_png(mapping[page_num.to_s], page_dir)
    else
      puts "  [INFO] Nessun PNG principale per pagina #{page_num}"
    end

    # Copia immagini illustrative con nomi originali
    if images_to_copy.empty?
      puts "  [INFO] Nessuna illustrazione trovata nell'HTML"
    else
      images_to_copy.each do |img_file|
        copy_illustration(img_file, page_dir)
      end
    end

    @stats[:processed] += 1
  end

  def copy_html(html_path, page_dir)
    source = html_path
    dest = "#{page_dir}/#{File.basename(html_path)}"

    copy_file(source, dest, "HTML originale")
  end

  def copy_page_png(png_file, page_dir)
    source = "#{source_dir}/#{book_id}/pages/#{png_file}"
    dest = "#{page_dir}/page.png"

    copy_file(source, dest, "PNG principale")
  end

  def copy_illustration(img_file, page_dir)
    source = "#{source_dir}/#{book_id}/epub/images/#{img_file}"
    dest = "#{page_dir}/#{img_file}"

    copy_file(source, dest, "Illustrazione")
  end

  def copy_file(source, dest, type)
    # Verifica se il file destinazione esiste già
    if File.exist?(dest)
      puts "  [SKIP] #{type}: #{File.basename(dest)} già esistente"
      return
    end

    # Verifica se il file sorgente esiste
    unless File.exist?(source)
      puts "  [ERROR] #{type}: file sorgente non trovato"
      puts "         Cercato: #{source}"
      @stats[:errors] << "Missing: #{source}"
      return
    end

    # In modalità dry-run, solo simula
    if dry_run
      puts "  [DRY-RUN] #{type}: #{File.basename(source)} -> #{File.basename(dest)}"
      @stats[:copied_files] += 1
    else
      # Copia effettiva del file
      begin
        FileUtils.cp(source, dest)
        puts "  [OK] #{type}: #{File.basename(source)} -> #{File.basename(dest)}"
        @stats[:copied_files] += 1
      rescue => e
        puts "  [ERROR] #{type}: #{e.message}"
        @stats[:errors] << "#{source}: #{e.message}"
      end
    end
  end

  def print_report
    puts "\n" + "=" * 60
    puts "REPORT FINALE"
    puts "=" * 60
    puts "Modalità: #{dry_run ? 'DRY-RUN' : 'ESECUZIONE'}"
    puts "Pagine processate: #{@stats[:processed]}"
    puts "Pagine saltate: #{@stats[:skipped]}"
    puts "Directory create: #{@stats[:created_dirs]}"
    puts "File copiati: #{@stats[:copied_files]}"
    puts "Errori: #{@stats[:errors].length}"

    if @stats[:errors].any?
      puts "\nDettaglio errori:"
      @stats[:errors].first(10).each { |e| puts "  - #{e}" }
      puts "  ... e altri #{@stats[:errors].length - 10} errori" if @stats[:errors].length > 10
    end

    if dry_run
      puts "\n*** Nessun file è stato realmente copiato (dry-run) ***"
      puts "Esegui senza 'dry_run' per copiare effettivamente i file"
    end

    puts "=" * 60
  end
end
