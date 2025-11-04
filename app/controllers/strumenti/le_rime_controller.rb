class Strumenti::LeRimeController < ApplicationController
  def show
    @poesia = params[:poesia] || ""
    @rhyme_groups = parse_poesia_and_detect_rhymes(@poesia) if @poesia.present?
  end

  private

  def parse_poesia_and_detect_rhymes(poesia_text)
    lines = poesia_text.split("\n").map(&:strip).reject(&:blank?)
    return [] if lines.empty?

    # Extract last word from each line (rimando)
    last_words = lines.map do |line|
      # Remove punctuation and get last word
      cleaned_line = line.gsub(/[.,;:!?()\[\]{}"]/, '')
      words = cleaned_line.split(/\s+/)
      last_word = words.last&.downcase
      { line: line, last_word: last_word, original_last_word: words.last }
    end

    # Group words by rhyme (last 2-3 characters)
    rhyme_groups = {}
    group_id = 1

    last_words.each_with_index do |word_data, index|
      next if word_data[:last_word].blank?

      # Try to find matching rhyme group
      found_group = nil
      rhyme_groups.each do |group_key, group_data|
        if rhymes?(word_data[:last_word], group_data[:last_word])
          found_group = group_key
          break
        end
      end

      if found_group
        rhyme_groups[found_group][:words] << { index: index, word: word_data[:original_last_word], line: word_data[:line] }
      else
        rhyme_groups[group_id] = {
          last_word: word_data[:last_word],
          words: [{ index: index, word: word_data[:original_last_word], line: word_data[:line] }]
        }
        group_id += 1
      end
    end

    # Convert to array and filter groups with at least 2 words (actual rhymes)
    rhyme_groups.values.select { |group| group[:words].length >= 2 }.map.with_index do |group, idx|
      {
        group_id: idx + 1,
        words: group[:words]
      }
    end
  end

  def rhymes?(word1, word2)
    return false if word1.blank? || word2.blank?

    # For Italian rhymes, compare last 2-3 characters
    # Remove common endings and compare
    word1_ending = extract_rhyme_sound(word1)
    word2_ending = extract_rhyme_sound(word2)

    word1_ending == word2_ending && word1_ending.length >= 2
  end

  def extract_rhyme_sound(word)
    # Remove accents and normalize
    normalized = word.downcase
                      .gsub(/[àáâãäå]/, 'a')
                      .gsub(/[èéêë]/, 'e')
                      .gsub(/[ìíîï]/, 'i')
                      .gsub(/[òóôõö]/, 'o')
                      .gsub(/[ùúûü]/, 'u')

    # Get last 2-4 characters (typically enough for Italian rhymes)
    # Try last 3 first (most common), then 2, then 4
    if normalized.length >= 3
      normalized[-3..-1]
    elsif normalized.length >= 2
      normalized[-2..-1]
    else
      normalized
    end
  end
end

