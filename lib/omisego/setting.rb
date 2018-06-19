module OmiseGO
  class Setting < Base
    attributes :tokens

    class << self
      def all(client: nil)
        request(client).send('settings.all', {}).data
      end
    end

    def tokens
      @_tokens ||= @tokens.map do |token|
        Token.new(token)
      end
    end
  end
end
