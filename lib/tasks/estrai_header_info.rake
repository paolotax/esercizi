#!/usr/bin/env ruby
require 'nokogiri'

namespace :pages do
  desc "Estrae sottotitolo e colore dagli header ERB per aggiornare il seed"
  task :extract_headers, [:prefix] => :environment do |t, args|
    prefix = args[:prefix] || 'nvl5_gram'

    puts "=" * 80
    puts "ESTRAZIONE HEADER INFO: #{prefix}"
    puts "=" * 80

    views_dir = Rails.root.join('app/views/exercises')
    erb_files = Dir.glob("#{views_dir}/#{prefix}_p*.html.erb").sort

    if erb_files.empty?
      puts "Nessun file trovato per #{prefix}"
      return
    end

    results = []

    erb_files.each do |file_path|
      filename = File.basename(file_path, '.html.erb')

      # Leggi il contenuto
      content = File.read(file_path)

      # Estrai info
      info = extract_header_info(content, filename)

      if info
        results << info
        puts "✓ #{filename}: #{info[:sottotitolo]} (#{info[:base_color]})"
      else
        puts "✗ #{filename}: Header non trovato o non standard"
      end
    end

    puts "\n" + "=" * 80
    puts "AGGIORNAMENTO SEED - Copia e incolla questo nel seed.rb:"
    puts "=" * 80
    puts

    # Genera output per seed
    results.group_by { |r| r[:disciplina] }.each do |disciplina, pages|
      puts "# #{disciplina}"
      puts "["

      pages.each_with_index do |page, idx|
        comma = idx < pages.length - 1 ? "," : ""
        puts "  { numero: #{page[:numero]}, titolo: \"#{page[:titolo]}\", slug: \"#{page[:slug]}\", view_template: \"#{page[:slug]}\", sottotitolo: \"#{page[:sottotitolo]}\", base_color: \"#{page[:base_color]}\" }#{comma}"
      end

      puts "].each do |pagina_data|"
      puts "  #{disciplina.downcase}_disciplina.pagine.create!(pagina_data)"
      puts "end"
      puts
    end

    puts "=" * 80
    puts "Totale pagine analizzate: #{results.length}/#{erb_files.length}"
    puts "=" * 80
  end

  def extract_header_info(content, filename)
    # Estrai numero pagina dal filename (es: nvl5_gram_p026 -> 26)
    match = filename.match(/_p(\d+)$/)
    return nil unless match

    numero = match[1].to_i

    # Parse HTML
    doc = Nokogiri::HTML(content)

    # Cerca sottotitolo (badge categoria)
    # Pattern 1: div con bg-COLORE-500 che contiene il sottotitolo
    badge_div = doc.css('div[class*="bg-"][class*="-500"]').find do |div|
      div['class'].match?(/bg-(blue|purple|cyan|green|orange|red|pink)-500/) &&
      div['class'].include?('text-white') &&
      div['class'].include?('rounded-lg')
    end

    if badge_div
      sottotitolo = badge_div.text.strip

      # Estrai colore dal badge
      color_match = badge_div['class'].match(/bg-(blue|purple|cyan|green|orange|red|pink)-500/)
      base_color = color_match[1] if color_match

      # Estrai titolo (h1)
      h1 = doc.css('h1').first
      titolo = h1.text.strip if h1

      # Determina disciplina dal filename
      disciplina = filename.match(/_([a-z]+)_p\d+$/)[1] rescue 'unknown'

      return {
        numero: numero,
        titolo: titolo || "Pagina #{numero}",
        slug: filename,
        sottotitolo: sottotitolo,
        base_color: base_color,
        disciplina: disciplina
      }
    end

    # Fallback: cerca nel partial render se presente
    if content.include?("render 'shared/page_header'")
      # Estrai parametri dal render
      if match = content.match(/sottotitolo:\s*['"]([^'"]+)['"]/)
        sottotitolo = match[1]
      end

      if match = content.match(/colore:\s*['"]([^'"]+)['"]/)
        base_color = match[1]
      end

      if match = content.match(/titolo:\s*['"]([^'"]+)['"]/)
        titolo = match[1]
      end

      if sottotitolo && base_color
        disciplina = filename.match(/_([a-z]+)_p\d+$/)[1] rescue 'unknown'

        return {
          numero: numero,
          titolo: titolo || "Pagina #{numero}",
          slug: filename,
          sottotitolo: sottotitolo,
          base_color: base_color,
          disciplina: disciplina
        }
      end
    end

    nil
  rescue => e
    puts "ERROR parsing #{filename}: #{e.message}"
    nil
  end
end
