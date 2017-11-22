module OmiseGO
  class Setting < Base
    attributes :minted_tokens

    class << self
      def all(client: nil)
        request(client).send('/get_settings', {}).data
      end
    end

    def minted_tokens
      @_minted_tokens ||= @minted_tokens.map do |minted_token|
        MintedToken.new(minted_token)
      end
    end
  end
end
