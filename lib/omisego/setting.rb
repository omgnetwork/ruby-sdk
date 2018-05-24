module OmiseGO
  class Setting < Base
    attributes :tokens

    class << self
      def all(client: nil)
        request(client).send('get_settings', {}).data
      end
    end

    def tokens
      @_tokens ||= @tokens.map do |token|
        Token.new(token)
      end
    end
  end
end
