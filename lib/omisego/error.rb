module OmiseGO
  class Error < Base
    attributes :code, :description, :messages

    def to_s
      "#{code} - #{description}"
    end

    def success?
      false
    end

    def error?
      true
    end
  end
end
