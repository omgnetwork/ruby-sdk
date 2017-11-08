module OmiseGO
  class ErrorHandler
    ERRORS = {
      nil_id: {
        code: 'user:nil_id',
        description: 'The given ID was nil.'
      }
    }.freeze

    class << self
      def handle(code)
        Error.new(code: ERRORS[code][:code],
                  description: ERRORS[code][:description])
      end
    end
  end
end
