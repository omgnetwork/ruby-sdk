module OmiseGO
  class Error < Base
    attributes :code, :description, :messages

    def to_s
      "#{code} - #{description}"
    end
  end
end
