#!/usr/bin/env ruby
require "fileutils"

namespace :images do
  desc "Pulisce HTML vuoti con 'Questa pagina non ha contenuti ad alta leggibilità'"
  task :clean, [ :prefix ] => :environment do |t, args|
    cleaner = HtmlCleaner.new(
      prefix: args[:prefix],  # es: 'nvl5_gram' o nil per tutti
      base_dir: Rails.root.join("app/assets/images")
    )
    cleaner.run
  end
end

class HtmlCleaner
  attr_reader :prefix, :base_dir

  def initialize(prefix:, base_dir:)
    @prefix = prefix
    @base_dir = base_dir
    @stats = { found: 0, deleted: 0, errors: [] }
  end

  def run
    puts "=" * 60
    puts "PULIZIA HTML VUOTI"
    puts prefix ? "Libro: #{prefix}" : "TUTTI I LIBRI"
    puts "=" * 60

    # Determina le directory da processare
    if prefix
      # Pulisci solo il libro specificato
      book_dir = "#{base_dir}/#{prefix}"
      if Dir.exist?(book_dir)
        puts "\nProcessando: #{prefix}"
        process_book(book_dir, prefix)
      else
        puts "ERRORE: Directory non trovata: #{book_dir}"
        return
      end
    else
      # Pulisci tutti i libri (directory che contengono sottocartelle pXXX)
      puts "\nCercando libri in #{base_dir}..."

      Dir.glob("#{base_dir}/*").each do |book_path|
        next unless File.directory?(book_path)

        book_name = File.basename(book_path)
        # Verifica se è una directory di libro (contiene cartelle pXXX)
        if has_page_folders?(book_path)
          puts "\nProcessando: #{book_name}"
          process_book(book_path, book_name)
        end
      end
    end

    print_report
  end

  private

  def has_page_folders?(book_path)
    Dir.glob("#{book_path}/p[0-9][0-9][0-9]").any?
  end

  def process_book(book_path, book_name)
    # Trova tutti gli HTML nel libro
    html_files = Dir.glob("#{book_path}/p*/*.html")

    if html_files.empty?
      puts "  Nessun file HTML trovato"
      return
    end

    puts "  Controllando #{html_files.length} file HTML..."

    html_files.each do |html_path|
      check_and_clean(html_path)
    end
  end

  def check_and_clean(html_path)
    begin
      content = File.read(html_path)

      if content.include?("Questa pagina non ha contenuti ad alta leggibilità")
        @stats[:found] += 1

        # Estrai info per il report
        page_dir = File.dirname(html_path)
        page_num = File.basename(page_dir)
        html_name = File.basename(html_path)

        # Elimina il file
        File.delete(html_path)
        puts "  [DELETED] #{page_num}/#{html_name}"
        @stats[:deleted] += 1

        # Se la cartella contiene solo page.png ora, segnalalo
        remaining_files = Dir.glob("#{page_dir}/*")
        if remaining_files.length == 1 && remaining_files.first.end_with?("page.png")
          puts "           -> Cartella #{page_num} ora contiene solo page.png"
        end
      end
    rescue => e
      @stats[:errors] << "#{html_path}: #{e.message}"
      puts "  [ERROR] #{File.basename(html_path)}: #{e.message}"
    end
  end

  def print_report
    puts "\n" + "=" * 60
    puts "REPORT PULIZIA"
    puts "=" * 60
    puts "HTML vuoti trovati: #{@stats[:found]}"
    puts "File eliminati: #{@stats[:deleted]}"
    puts "Errori: #{@stats[:errors].length}"

    if @stats[:errors].any?
      puts "\nDettaglio errori:"
      @stats[:errors].each { |e| puts "  - #{e}" }
    end

    if @stats[:deleted] > 0
      puts "\n✅ Pulizia completata con successo!"
      puts "   Eliminati #{@stats[:deleted]} file HTML vuoti"
    else
      puts "\n✓ Nessun file da pulire trovato"
    end

    puts "=" * 60
  end
end

# Task aggiuntivo per analisi (solo report senza eliminare)
namespace :images do
  desc "Analizza HTML vuoti senza eliminarli"
  task :analyze, [ :prefix ] => :environment do |t, args|
    analyzer = HtmlAnalyzer.new(
      prefix: args[:prefix],
      base_dir: Rails.root.join("app/assets/images")
    )
    analyzer.run
  end
end

class HtmlAnalyzer < HtmlCleaner
  def check_and_clean(html_path)
    begin
      content = File.read(html_path)

      if content.include?("Questa pagina non ha contenuti ad alta leggibilità")
        @stats[:found] += 1

        # Solo report, non elimina
        page_dir = File.dirname(html_path)
        page_num = File.basename(page_dir)
        html_name = File.basename(html_path)
        file_size = File.size(html_path) / 1024.0  # KB

        puts "  [FOUND] #{page_num}/#{html_name} (#{file_size.round(1)} KB)"
      end
    rescue => e
      @stats[:errors] << "#{html_path}: #{e.message}"
      puts "  [ERROR] #{File.basename(html_path)}: #{e.message}"
    end
  end

  def print_report
    puts "\n" + "=" * 60
    puts "REPORT ANALISI"
    puts "=" * 60
    puts "HTML vuoti trovati: #{@stats[:found]}"
    puts "Errori: #{@stats[:errors].length}"

    if @stats[:found] > 0
      puts "\n⚠️  Trovati #{@stats[:found]} file HTML vuoti"
      puts "   Esegui 'rake images:clean' per eliminarli"
    else
      puts "\n✓ Nessun file HTML vuoto trovato"
    end

    puts "=" * 60
  end
end
