class Code
  ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789".freeze

  class << self
    def generate(length)
      length.times.map { ALPHABET[SecureRandom.random_number(ALPHABET.length)] }.join
    end

    def sanitize(code)
      code.to_s.upcase
        .tr("OI", "01")
        .tr("L", "1")
        .gsub(/[^#{ALPHABET}]/, "")
    end
  end
end
