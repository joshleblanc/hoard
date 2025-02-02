module Hoard
  class Utils
    def self.underscore(camel_cased_word)
      camel_cased_word.to_s.split("::").last.bytes.map.with_index do |byte, i|
        if byte >= 48 && byte < 97
          downcased = byte > 64 ? byte + 32 : byte
          i.zero? ? downcased.chr : "_#{downcased.chr}"
        else
          byte.chr
        end
      end.join
    end
  end
end
