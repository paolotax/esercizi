namespace :pages do
  desc "Popola sottotitolo e base_color nel database leggendo dagli ERB"
  task :populate_headers, [:prefix] => :environment do |t, args|
    prefix = args[:prefix] || 'nvl5_gram'

    puts "=" * 80
    puts "POPOLAMENTO DATABASE: #{prefix}"
    puts "=" * 80

    views_dir = Rails.root.join('app/views/exercises')
    erb_files = Dir.glob("#{views_dir}/#{prefix}_p*.html.erb").sort

    updated = 0
    skipped = 0

    erb_files.each do |file_path|
      filename = File.basename(file_path, '.html.erb')

      # Trova la pagina nel database
      pagina = Pagina.find_by(slug: filename)

      unless pagina
        puts "✗ #{filename}: non trovata nel database"
        skipped += 1
        next
      end

      # Estrai info dall'ERB
      content = File.read(file_path)
      doc = Nokogiri::HTML(content)

      # Cerca badge sottotitolo
      badge_div = doc.css('div[class*="bg-"][class*="-500"]').find do |div|
        div['class'].match?(/bg-(blue|purple|cyan|green|orange|red|pink)-500/) &&
        div['class'].include?('text-white') &&
        div['class'].include?('rounded-lg')
      end

      if badge_div
        sottotitolo = badge_div.text.strip
        color_match = badge_div['class'].match(/bg-(blue|purple|cyan|green|orange|red|pink)-500/)
        base_color = color_match[1] if color_match

        # Aggiorna il database
        pagina.update!(sottotitolo: sottotitolo, base_color: base_color)
        puts "✓ #{filename}: #{sottotitolo} (#{base_color})"
        updated += 1
      else
        puts "✗ #{filename}: Header non trovato"
        skipped += 1
      end
    rescue => e
      puts "✗ #{filename}: ERROR - #{e.message}"
      skipped += 1
    end

    puts "\n" + "=" * 80
    puts "RIEPILOGO"
    puts "=" * 80
    puts "Aggiornate: #{updated}"
    puts "Saltate: #{skipped}"
    puts "=" * 80
  end
end
