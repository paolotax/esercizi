# frozen_string_literal: true

namespace :esercizi do
  desc "Estrae esercizi con helper grid da pagine ERB e crea record Esercizio con Question"
  task :estrai_grid, [ :prefix, :dry_run ] => :environment do |_t, args|
    prefix = args[:prefix] || "nvi4_mat"
    dry_run = args[:dry_run] == "dry_run"

    extractor = EserciziGridExtractor.new(prefix: prefix, dry_run: dry_run)
    extractor.run
  end
end

class EserciziGridExtractor
  GRID_HELPERS = {
    "addizione_grid" => "Addizione",
    "sottrazione_grid" => "Sottrazione",
    "moltiplicazione_grid" => "Moltiplicazione",
    "divisione_grid" => "Divisione"
  }.freeze

  # Regex che cattura anche varianti con parametri extra: numero_esercizio_badge(2, colore: "red-500")
  BADGE_REGEX = /numero_esercizio_badge\s*\(\s*(\d+)(?:\s*,\s*[^)]+)?\s*\)/
  GRID_REGEX = /(addizione_grid|sottrazione_grid|moltiplicazione_grid|divisione_grid)/

  # Regex per estrarre i parametri degli helper
  ADDIZIONE_REGEX = /addizione_grid\s+\[([^\]]+)\](?:,\s*(.+?))?(?:\s*%>)/
  SOTTRAZIONE_REGEX = /sottrazione_grid\s+(\d+),\s*(\d+)(?:,\s*(.+?))?(?:\s*%>)/
  MOLTIPLICAZIONE_REGEX = /moltiplicazione_grid\s+(\d+),\s*(\d+)(?:,\s*(.+?))?(?:\s*%>)/
  DIVISIONE_REGEX = /divisione_grid\s+(\d+),\s*(\d+)(?:,\s*(.+?))?(?:\s*%>)/

  # Default user e account per assegnazione
  DEFAULT_CREATOR_EMAIL = "paolo.tassinari@hey.com"

  def initialize(prefix:, dry_run: false)
    @prefix = prefix
    @dry_run = dry_run
    @created_esercizi = 0
    @created_questions = 0
    @skipped = 0
    @errors = []
  end

  def run
    puts header

    # Trova utente e account di default
    find_default_user_and_account

    erb_files.each { |file| process_file(file) }

    puts summary
  end

  private

  def find_default_user_and_account
    identity = Identity.find_by(email_address: DEFAULT_CREATOR_EMAIL)
    if identity
      @default_user = User.find_by(identity_id: identity.id)
      @default_account_id = @default_user&.account_id
      puts "  Assegnazione a: #{@default_user&.name} (account_id: #{@default_account_id})"
    else
      puts "  ATTENZIONE: Utente #{DEFAULT_CREATOR_EMAIL} non trovato, esercizi senza assegnazione"
    end
  end

  def erb_files
    views_dir = Rails.root.join("app/views/exercises")
    Dir.glob("#{views_dir}/#{@prefix}_p*.html.erb").sort
  end

  def process_file(file_path)
    filename = File.basename(file_path, ".html.erb")
    content = File.read(file_path)

    puts "\n--- #{filename} ---"

    exercises = extract_exercises(content, filename)

    if exercises.empty?
      puts "  Nessun esercizio con grid trovato"
      return
    end

    exercises.each do |exercise_data|
      create_esercizio_with_questions(exercise_data)
    end
  rescue => e
    @errors << { file: filename, error: e.message }
    puts "  ERROR: #{e.message}"
    puts e.backtrace.first(3).join("\n") if ENV["DEBUG"]
  end

  def extract_exercises(content, page_slug)
    exercises = []

    # Dividi il contenuto in blocchi usando i badge come separatori
    blocks = split_into_exercise_blocks(content)

    blocks.each do |block|
      # Salta blocchi senza helper grid
      next unless block.match?(GRID_REGEX)

      exercise = parse_exercise_block(block, page_slug)
      exercises << exercise if exercise
    end

    exercises
  end

  def split_into_exercise_blocks(content)
    # Trova tutte le posizioni dei badge
    badge_positions = []
    content.scan(BADGE_REGEX) do
      badge_positions << Regexp.last_match.begin(0)
    end

    return [ content ] if badge_positions.empty?

    # Dividi il contenuto in blocchi basati sulle posizioni dei badge
    blocks = []
    badge_positions.each_with_index do |pos, idx|
      end_pos = badge_positions[idx + 1] || content.length
      blocks << content[pos...end_pos]
    end

    blocks
  end

  def parse_exercise_block(block, page_slug)
    # Estrai numero esercizio
    numero_match = block.match(BADGE_REGEX)
    return nil unless numero_match

    numero = numero_match[1].to_i

    # Estrai tutte le operazioni grid con i loro parametri
    operations = extract_operations(block)

    return nil if operations.empty?

    # Determina la categoria
    categories = operations.map { |op| op[:type].downcase }.uniq
    category = categories.length == 1 ? categories.first : categories.join("_")

    # Estrai testo istruzioni
    title = extract_instruction_text(block)

    {
      numero: numero,
      page_slug: page_slug,
      category: category,
      title: title,
      operations: operations
    }
  end

  def extract_operations(block)
    operations = []

    # Estrai addizioni: addizione_grid [num1, num2, ...], options
    block.scan(/addizione_grid\s+\[([^\]]+)\]/) do |match|
      addends_str = match[0]
      addends = addends_str.split(",").map(&:strip).map(&:to_i)
      operations << { type: "Addizione", params: { addends: addends } }
    end

    # Estrai sottrazioni: sottrazione_grid num1, num2, options
    block.scan(/sottrazione_grid\s+(\d+),\s*(\d+)/) do |match|
      minuend = match[0].to_i
      subtrahend = match[1].to_i
      operations << { type: "Sottrazione", params: { minuend: minuend, subtrahend: subtrahend } }
    end

    # Estrai moltiplicazioni: moltiplicazione_grid num1, num2, options
    block.scan(/moltiplicazione_grid\s+(\d+),\s*(\d+)/) do |match|
      multiplicand = match[0].to_i
      multiplier = match[1].to_i
      operations << { type: "Moltiplicazione", params: { multiplicand: multiplicand, multiplier: multiplier } }
    end

    # Estrai divisioni: divisione_grid num1, num2, options
    block.scan(/divisione_grid\s+(\d+),\s*(\d+)/) do |match|
      dividend = match[0].to_i
      divisor = match[1].to_i
      operations << { type: "Divisione", params: { dividend: dividend, divisor: divisor } }
    end

    operations
  end

  def extract_instruction_text(block)
    # Pattern: cerca il testo dopo il badge e prima di </p>
    if (match = block.match(/numero_esercizio_badge\s*\(\s*\d+\s*\)\s*%>\s*(.+?)\s*<\/p>/m))
      text = match[1]
      # Rimuovi tag HTML e pulisci whitespace
      text = text.gsub(/<[^>]+>/, " ")
                 .gsub(/\s+/, " ")
                 .strip

      return text if text.present? && text.length > 3
    end

    "Esercizio con operazioni in colonna"
  end

  def create_esercizio_with_questions(data)
    title = data[:title]
    description = "Esercizio #{data[:numero]} - #{data[:page_slug]}"
    category = data[:category]
    tags = [ data[:page_slug], "grid", category ]
    operations = data[:operations]

    if @dry_run
      puts "  [DRY-RUN] #{title}"
      puts "            Descrizione: #{description}"
      puts "            Categoria: #{category}"
      operations.each_with_index do |op, idx|
        puts "            Question #{idx + 1}: #{op[:type]} - #{op[:params]}"
      end
      @created_esercizi += 1
      @created_questions += operations.count
      return
    end

    # Crea l'esercizio
    esercizio = Esercizio.new(
      title: title,
      description: description,
      category: category,
      tags: tags,
      creator_id: @default_user&.id,
      account_id: @default_account_id
    )

    unless esercizio.save
      puts "  ERRORE Esercizio: #{esercizio.errors.full_messages.join(', ')}"
      @errors << { title: title, error: esercizio.errors.full_messages.join(", ") }
      return
    end

    puts "  CREATO: [#{esercizio.slug}] #{title}"
    @created_esercizi += 1

    # Crea le Question con i questionable
    operations.each_with_index do |op, idx|
      create_question(esercizio, op, idx + 1)
    end
  end

  def create_question(esercizio, operation, position)
    # Crea il questionable (Addizione, Sottrazione, etc.)
    questionable_class = operation[:type].constantize
    questionable = questionable_class.new(operation[:params])

    unless questionable.save
      puts "    ERRORE #{operation[:type]}: #{questionable.errors.full_messages.join(', ')}"
      @errors << { esercizio: esercizio.slug, error: questionable.errors.full_messages.join(", ") }
      return
    end

    # Crea la Question
    question = esercizio.questions.new(
      questionable: questionable,
      position: position,
      creator_id: @default_user&.id,
      account_id: @default_account_id
    )

    if question.save
      puts "    + Question #{position}: #{operation[:type]} #{format_operation(operation)}"
      @created_questions += 1
    else
      puts "    ERRORE Question: #{question.errors.full_messages.join(', ')}"
      @errors << { esercizio: esercizio.slug, error: question.errors.full_messages.join(", ") }
    end
  end

  def format_operation(operation)
    case operation[:type]
    when "Addizione"
      operation[:params][:addends].join(" + ")
    when "Sottrazione"
      "#{operation[:params][:minuend]} - #{operation[:params][:subtrahend]}"
    when "Moltiplicazione"
      "#{operation[:params][:multiplicand]} x #{operation[:params][:multiplier]}"
    when "Divisione"
      "#{operation[:params][:dividend]} : #{operation[:params][:divisor]}"
    else
      operation[:params].to_s
    end
  end

  def header
    <<~HEADER

      #{'=' * 70}
      ESTRAZIONE ESERCIZI GRID: #{@prefix}
      Modalita: #{@dry_run ? 'DRY-RUN (nessuna modifica al database)' : 'LIVE'}
      #{'=' * 70}
    HEADER
  end

  def summary
    error_details = @errors.map { |e| "  - #{e[:file] || e[:title] || e[:esercizio]}: #{e[:error]}" }.join("\n")

    <<~SUMMARY

      #{'=' * 70}
      RIEPILOGO
      #{'=' * 70}
      Esercizi creati: #{@created_esercizi}
      Questions create: #{@created_questions}
      Saltati: #{@skipped}
      Errori: #{@errors.count}
      #{error_details if @errors.any?}
      #{'=' * 70}
    SUMMARY
  end
end
