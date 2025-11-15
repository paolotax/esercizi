namespace :pages do
  desc "Aggiorna il seed con sottotitolo e base_color estratti"
  task :update_seed, [:prefix] => :environment do |t, args|
    prefix = args[:prefix] || 'nvl5_gram'

    puts "Aggiornamento seed per #{prefix}..."

    # Leggi il seed attuale
    seed_file = Rails.root.join('db/seeds.rb')
    content = File.read(seed_file)

    # Trova tutte le pagine di questo prefix nel database
    pagine = Pagina.joins(:disciplina, disciplina: :volume)
                   .where("pagine.slug LIKE ?", "#{prefix}%")
                   .where.not(sottotitolo: nil)
                   .order(:numero)

    puts "Trovate #{pagine.count} pagine con sottotitolo/base_color nel database"

    # Per ogni pagina, aggiorna nel seed
    updated_count = 0
    pagine.each do |pagina|
      # Pattern regex per trovare la riga della pagina
      pattern = /(\{\s*numero:\s*#{pagina.numero},\s*titolo:\s*"[^"]+",\s*slug:\s*"#{pagina.slug}",\s*view_template:\s*"#{pagina.slug}")\s*\}/

      replacement = "{ numero: #{pagina.numero}, titolo: \"#{pagina.titolo}\", slug: \"#{pagina.slug}\", view_template: \"#{pagina.slug}\", sottotitolo: \"#{pagina.sottotitolo}\", base_color: \"#{pagina.base_color}\" }"

      if content.match?(pattern)
        content.gsub!(pattern, replacement)
        updated_count += 1
        puts "✓ Aggiornata pagina #{pagina.numero}: #{pagina.sottotitolo} (#{pagina.base_color})"
      end
    end

    # Salva il seed aggiornato
    File.write(seed_file, content)

    puts "\n✅ Seed aggiornato! #{updated_count} pagine modificate."
    puts "Rigenera il database con: bin/rails db:seed"
  end
end
