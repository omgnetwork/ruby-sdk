module OmiseGO
  class Error < Base
    attributes :code, :description, :messages

    def to_s
      "#{code} - #{description}"
    end

    def error?
      true
    end
  end
end
