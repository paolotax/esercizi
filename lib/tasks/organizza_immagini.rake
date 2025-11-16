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

  desc "Mostra statistiche per libro (HTML, PNG, immagini)"
  task :stats, [ :prefix, :book_id ] => :environment do |t, args|
    unless args[:prefix]
      puts "ERRORE: Specifica il prefix del libro"
      puts "Esempio: rake images:stats[nvl5_gram]"
      puts "         rake images:stats[nvl5_gram,book_844]  (con controllo sorgente)"
      exit 1
    end

    stats = ImageStats.new(
      prefix: args[:prefix],
      dest_dir: Rails.root.join("app/assets/images"),
      book_id: args[:book_id],
      source_dir: File.expand_path("~/Windows")
    )
    stats.show
  end

  desc "Trova e copia immagini orfane (non referenziate negli HTML)"
  task :find_orphans, [ :prefix, :book_id ] => :environment do |t, args|
    unless args[:prefix] && args[:book_id]
      puts "ERRORE: Specifica prefix e book_id"
      puts "Esempio: rake images:find_orphans[nvi5_mat,book_882]"
      exit 1
    end

    finder = OrphanImageFinder.new(
      prefix: args[:prefix],
      book_id: args[:book_id],
      source_dir: File.expand_path("~/Windows"),
      dest_dir: Rails.root.join("app/assets/images")
    )
    finder.find_and_copy
  end

  desc "Sposta immagini orfane nella cartella corretta basandosi sul nome file"
  task :place_orphans, [ :prefix ] => :environment do |t, args|
    unless args[:prefix]
      puts "ERRORE: Specifica il prefix"
      puts "Esempio: rake images:place_orphans[nvi5_mat]"
      exit 1
    end

    placer = OrphanImagePlacer.new(
      prefix: args[:prefix],
      dest_dir: Rails.root.join("app/assets/images")
    )
    placer.place_images
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
    @stats = {
      processed: 0,
      skipped: 0,
      copied_files: 0,
      created_dirs: 0,
      errors: [],
      existing_png: 0,
      existing_html: 0,
      existing_images: 0
    }
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

    # Parse tutti gli HTML per trovare le immagini PRIMA di copiarli
    # (così le immagini vengono sempre processate, anche se gli HTML esistono già)
    images_to_copy = []

    # Processa HTML dalla directory sorgente
    if html_files.any?
      html_files.each do |html_file|
        begin
          content = File.read(html_file)
          # Salta HTML vuoti
          next if content.include?("Questa pagina non ha contenuti ad alta leggibilità")

          doc = Nokogiri::HTML(content)
          images = doc.css("img").map { |img| img["src"] }.compact
          new_images = images.select { |src| src.include?("images/") }
                             .map { |src| File.basename(src) }

          # Aggiungi le nuove immagini trovate (evita duplicati)
          images_to_copy = (images_to_copy + new_images).uniq
        rescue => e
          puts "  [ERROR] Errore parsing HTML #{File.basename(html_file)}: #{e.message}"
          @stats[:errors] << "#{html_file}: #{e.message}"
        end
      end
    end

    # Se ci sono già HTML nella destinazione, controlla anche quelli per immagini mancanti
    if Dir.exist?(page_dir)
      dest_html_files = Dir.glob("#{page_dir}/*.html")
      if dest_html_files.any?
        dest_html_files.each do |html_file|
          begin
            content = File.read(html_file)
            # Salta HTML vuoti
            next if content.include?("Questa pagina non ha contenuti ad alta leggibilità")

            doc = Nokogiri::HTML(content)
            images = doc.css("img").map { |img| img["src"] }.compact
            new_images = images.select { |src| src.include?("images/") }
                               .map { |src| File.basename(src) }

            # Aggiungi le nuove immagini trovate (evita duplicati)
            images_to_copy = (images_to_copy + new_images).uniq
          rescue => e
            puts "  [ERROR] Errore parsing HTML destinazione #{File.basename(html_file)}: #{e.message}"
            @stats[:errors] << "#{html_file}: #{e.message}"
          end
        end
      end
    end

    # Copia TUTTI gli HTML trovati con i loro nomi originali
    html_files.each do |html_path|
      copy_html(html_path, page_dir)
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
      puts "  [INFO] Trovate #{images_to_copy.length} illustrazione/i da processare"
      images_to_copy.each do |img_file|
        copy_illustration(img_file, page_dir)
      end
    end

    @stats[:processed] += 1
  end

  def copy_html(html_path, page_dir)
    source = html_path
    dest = "#{page_dir}/#{File.basename(html_path)}"

    # Controlla se l'HTML contiene il messaggio di contenuto vuoto
    if File.exist?(source)
      content = File.read(source)
      if content.include?("Questa pagina non ha contenuti ad alta leggibilità")
        puts "  [SKIP] HTML vuoto: #{File.basename(source)} (non ha contenuti ad alta leggibilità)"
        return
      end
    end

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
      # Traccia i file già esistenti per tipo
      if type == "PNG principale"
        @stats[:existing_png] += 1
      elsif type == "HTML originale"
        @stats[:existing_html] += 1
      elsif type == "Illustrazione"
        @stats[:existing_images] += 1
      end
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

  def count_existing_files
    base_dir = "#{dest_dir}/#{prefix}"
    return { png: 0, html: 0, images: 0, total: 0 } unless Dir.exist?(base_dir)

    png_count = 0
    html_count = 0
    image_count = 0

    Dir.glob("#{base_dir}/**/*").each do |file|
      next unless File.file?(file)
      ext = File.extname(file).downcase
      if ext == ".png" && File.basename(file) == "page.png"
        png_count += 1
      elsif ext == ".html"
        html_count += 1
      elsif [ ".jpg", ".jpeg", ".gif", ".png" ].include?(ext) && File.basename(file) != "page.png"
        image_count += 1
      end
    end

    { png: png_count, html: html_count, images: image_count, total: png_count + html_count + image_count }
  end

  def print_report
    existing_files = count_existing_files

    puts "\n" + "=" * 60
    puts "REPORT FINALE"
    puts "=" * 60
    puts "Modalità: #{dry_run ? 'DRY-RUN' : 'ESECUZIONE'}"
    puts "Pagine processate: #{@stats[:processed]}"
    puts "Pagine saltate: #{@stats[:skipped]}"
    puts "Directory create: #{@stats[:created_dirs]}"
    puts "File copiati: #{@stats[:copied_files]}"
    puts "Errori: #{@stats[:errors].length}"
    puts ""
    puts "File già esistenti (saltati):"
    puts "  - PNG principali: #{@stats[:existing_png]}"
    puts "  - HTML: #{@stats[:existing_html]}"
    puts "  - Immagini illustrative: #{@stats[:existing_images]}"
    puts ""
    puts "File totali nella directory destinazione:"
    puts "  - PNG principali: #{existing_files[:png]}"
    puts "  - HTML: #{existing_files[:html]}"
    puts "  - Immagini illustrative: #{existing_files[:images]}"
    puts "  - TOTALE: #{existing_files[:total]}"

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

class ImageStats
  attr_reader :prefix, :dest_dir, :book_id, :source_dir

  def initialize(prefix:, dest_dir:, book_id: nil, source_dir: nil)
    @prefix = prefix
    @dest_dir = dest_dir
    @book_id = book_id
    @source_dir = source_dir
  end

  def show
    base_dir = "#{dest_dir}/#{prefix}"

    unless Dir.exist?(base_dir)
      puts "ERRORE: Directory non trovata: #{base_dir}"
      return
    end

    stats = analyze_directory(base_dir)
    source_stats = analyze_source_directory if book_id && source_dir

    puts "=" * 60
    puts "STATISTICHE LIBRO: #{prefix}"
    puts "=" * 60
    puts "Directory destinazione: #{base_dir}"
    if source_stats
      puts "Directory sorgente: #{source_dir}/#{book_id}/epub/images"
    end
    puts ""
    puts "RIEPILOGO COMPLESSIVO (DESTINAZIONE):"
    puts "  - Pagine trovate: #{stats[:pages].length}"
    puts "  - PNG principali: #{stats[:total_png]}"
    puts "  - HTML: #{stats[:total_html]}"
    puts "  - Immagini illustrative: #{stats[:total_images]}"
    puts "  - TOTALE FILE: #{stats[:total_files]}"

    if source_stats
      puts ""
      puts "RIEPILOGO SORGENTE:"
      puts "  - Immagini illustrative nella sorgente: #{source_stats[:source_images]}"
      puts ""
      puts "CONFRONTO:"
      diff = source_stats[:source_images] - stats[:total_images]
      if diff > 0
        puts "  - ⚠️  Mancano #{diff} immagini illustrative nella destinazione"
      elsif diff < 0
        puts "  - ⚠️  Ci sono #{diff.abs} immagini in più nella destinazione"
      else
        puts "  - ✓ Tutte le immagini sono state copiate"
      end
    end

    puts "=" * 60
  end

  private

  def analyze_directory(base_dir)
    stats = {
      pages: {},
      total_png: 0,
      total_html: 0,
      total_images: 0,
      total_files: 0
    }

    # Trova tutte le directory delle pagine (p001, p002, etc.)
    page_dirs = Dir.glob("#{base_dir}/p*").select { |d| File.directory?(d) }

    page_dirs.each do |page_dir|
      page_num = extract_page_number(page_dir)
      next unless page_num

      page_stats = analyze_page_directory(page_dir)
      stats[:pages][page_num] = page_stats
      stats[:total_png] += page_stats[:png]
      stats[:total_html] += page_stats[:html]
      stats[:total_images] += page_stats[:images]
      stats[:total_files] += page_stats[:total]
    end

    stats
  end

  def analyze_page_directory(page_dir)
    stats = {
      png: 0,
      html: 0,
      images: 0,
      total: 0,
      html_files: [],
      image_files: []
    }

    Dir.glob("#{page_dir}/*").each do |file|
      next unless File.file?(file)

      filename = File.basename(file)
      ext = File.extname(file).downcase

      if filename == "page.png"
        stats[:png] += 1
        stats[:total] += 1
      elsif ext == ".html"
        stats[:html] += 1
        stats[:total] += 1
        stats[:html_files] << filename
      elsif [ ".jpg", ".jpeg", ".gif", ".png" ].include?(ext)
        stats[:images] += 1
        stats[:total] += 1
        stats[:image_files] << filename
      end
    end

    stats
  end

  def extract_page_number(page_dir)
    match = File.basename(page_dir).match(/p(\d+)/)
    match ? match[1].to_i : nil
  end

  def analyze_source_directory
    images_dir = "#{source_dir}/#{book_id}/epub/images"

    unless Dir.exist?(images_dir)
      puts "WARNING: Directory sorgente immagini non trovata: #{images_dir}"
      return { source_images: 0 }
    end

    image_count = 0
    Dir.glob("#{images_dir}/*").each do |file|
      next unless File.file?(file)
      ext = File.extname(file).downcase
      if [ ".jpg", ".jpeg", ".gif", ".png" ].include?(ext)
        image_count += 1
      end
    end

    { source_images: image_count }
  end
end

class OrphanImageFinder
  attr_reader :prefix, :book_id, :source_dir, :dest_dir

  def initialize(prefix:, book_id:, source_dir:, dest_dir:)
    @prefix = prefix
    @book_id = book_id
    @source_dir = source_dir
    @dest_dir = dest_dir
  end

  def find_and_copy
    puts "=" * 60
    puts "RICERCA IMMAGINI ORFANE: #{book_id} -> #{prefix}"
    puts "=" * 60

    # 1. Trova tutte le immagini nella sorgente
    source_images_dir = "#{source_dir}/#{book_id}/epub/images"
    unless Dir.exist?(source_images_dir)
      puts "ERRORE: Directory sorgente non trovata: #{source_images_dir}"
      return
    end

    source_images = find_images_in_directory(source_images_dir)
    puts "\nImmagini nella sorgente: #{source_images.length}"

    # 2. Trova tutte le immagini nella destinazione (da tutte le pagine)
    dest_base_dir = "#{dest_dir}/#{prefix}"
    unless Dir.exist?(dest_base_dir)
      puts "ERRORE: Directory destinazione non trovata: #{dest_base_dir}"
      return
    end

    dest_images = find_all_dest_images(dest_base_dir)
    puts "Immagini nella destinazione: #{dest_images.length}"

    # 3. Identifica immagini orfane (presenti nella sorgente ma non nella destinazione)
    orphan_images = source_images - dest_images
    puts "\nImmagini orfane trovate: #{orphan_images.length}"

    if orphan_images.empty?
      puts "\n✓ Nessuna immagine orfana trovata!"
      return
    end

    # 4. Mostra l'elenco delle immagini orfane
    puts "\nElenco immagini orfane:"
    orphan_images.sort.each_with_index do |img, idx|
      puts "  #{idx + 1}. #{img}"
    end

    # 5. Copia le immagini orfane nella cartella images/orfane/{prefix}
    orphan_dir = "#{dest_dir}/orfane/#{prefix}"
    FileUtils.mkdir_p(orphan_dir)
    puts "\nCopiando immagini orfane in: #{orphan_dir}"

    copied = 0
    orphan_images.each do |img_name|
      source_path = "#{source_images_dir}/#{img_name}"
      dest_path = "#{orphan_dir}/#{img_name}"

      if File.exist?(source_path)
        if File.exist?(dest_path)
          puts "  [SKIP] #{img_name} già esistente"
        else
          FileUtils.cp(source_path, dest_path)
          puts "  [OK] #{img_name}"
          copied += 1
        end
      else
        puts "  [ERROR] File sorgente non trovato: #{source_path}"
      end
    end

    puts "\n" + "=" * 60
    puts "COMPLETATO"
    puts "=" * 60
    puts "Immagini orfane trovate: #{orphan_images.length}"
    puts "Immagini copiate: #{copied}"
    puts "Directory: #{orphan_dir}"
    puts "=" * 60
  end

  private

  def find_images_in_directory(dir)
    images = []
    Dir.glob("#{dir}/*").each do |file|
      next unless File.file?(file)
      ext = File.extname(file).downcase
      if [ ".jpg", ".jpeg", ".gif", ".png" ].include?(ext)
        images << File.basename(file)
      end
    end
    images
  end

  def find_all_dest_images(base_dir)
    all_images = []

    # Trova tutte le directory delle pagine
    page_dirs = Dir.glob("#{base_dir}/p*").select { |d| File.directory?(d) }

    page_dirs.each do |page_dir|
      Dir.glob("#{page_dir}/*").each do |file|
        next unless File.file?(file)
        filename = File.basename(file)
        ext = File.extname(file).downcase

        # Conta solo immagini illustrative (escludi page.png)
        if [ ".jpg", ".jpeg", ".gif", ".png" ].include?(ext) && filename != "page.png"
          all_images << filename
        end
      end
    end

    all_images.uniq
  end
end

class OrphanImagePlacer
  attr_reader :prefix, :dest_dir

  def initialize(prefix:, dest_dir:)
    @prefix = prefix
    @dest_dir = dest_dir
  end

  def place_images
    orphan_dir = "#{dest_dir}/orfane/#{prefix}"

    unless Dir.exist?(orphan_dir)
      puts "ERRORE: Directory orfane non trovata: #{orphan_dir}"
      return
    end

    puts "=" * 60
    puts "SPOSTAMENTO IMMAGINI ORFANE: #{prefix}"
    puts "=" * 60
    puts "Directory orfane: #{orphan_dir}"
    puts ""

    # Trova tutte le immagini nella cartella orfane
    orphan_images = Dir.glob("#{orphan_dir}/*").select { |f| File.file?(f) }

    if orphan_images.empty?
      puts "Nessuna immagine orfana trovata!"
      return
    end

    puts "Immagini da spostare: #{orphan_images.length}"
    puts ""

    stats = { placed: 0, skipped: 0, errors: 0 }

    orphan_images.each do |image_path|
      filename = File.basename(image_path)
      page_num = extract_page_number(filename)

      if page_num.nil?
        puts "  [ERROR] #{filename}: impossibile determinare il numero di pagina"
        stats[:errors] += 1
        next
      end

      page_str = page_num.to_s.rjust(3, "0")
      target_dir = "#{dest_dir}/#{prefix}/p#{page_str}"
      target_path = "#{target_dir}/#{filename}"

      # Crea la directory se non esiste
      unless Dir.exist?(target_dir)
        FileUtils.mkdir_p(target_dir)
        puts "  [OK] Directory creata: p#{page_str}"
      end

      # Controlla se il file esiste già
      if File.exist?(target_path)
        puts "  [SKIP] #{filename} -> p#{page_str}/ (già esistente)"
        # Elimina dalla cartella orfane visto che è già al suo posto
        FileUtils.rm(image_path)
        puts "  [DEL] #{filename} rimosso da orfane/"
        stats[:skipped] += 1
      else
        FileUtils.cp(image_path, target_path)
        puts "  [OK] #{filename} -> p#{page_str}/"
        # Elimina dalla cartella orfane dopo aver copiato
        FileUtils.rm(image_path)
        puts "  [DEL] #{filename} rimosso da orfane/"
        stats[:placed] += 1
      end
    end

    puts ""
    puts "=" * 60
    puts "COMPLETATO"
    puts "=" * 60
    puts "Immagini spostate: #{stats[:placed]}"
    puts "Immagini saltate (già esistenti): #{stats[:skipped]}"
    puts "Errori: #{stats[:errors]}"
    puts "=" * 60
  end

  private

  def extract_page_number(filename)
    # Caso 1: file che inizia con pXXX_ (es: p134_01.jpg)
    if match = filename.match(/^p(\d{3})_/)
      return match[1].to_i
    end

    # Caso 2: file con numero lungo prima di _ (es: output-1715938802134_697_772_114_103.png)
    # Trova il primo numero lungo prima di _
    if match = filename.match(/(\d{10,})_/)
      long_number = match[1]
      # Prendi le ultime 3 cifre
      page_num = long_number[-3..-1]
      return page_num.to_i if page_num
    end

    nil
  end
end
