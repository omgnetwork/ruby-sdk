module OmiseGO
  class Balance < Base
    attributes :amount

    class << self
      def all(provider_user_id:, client: nil)
        request(client).send('/user.list_balances', provider_user_id: provider_user_id).data
      end

      def credit(provider_user_id:, token_id:, amount:, metadata: {}, client: nil)
        request(client).send('/user.credit_balance', provider_user_id: provider_user_id,
                                                     token_id: token_id,
                                                     amount: amount,
                                                     metadata: metadata).data
      end

      def debit(provider_user_id:, token_id:, amount:, metadata: {}, client: nil)
        request(client).send('/user.debit_balance', provider_user_id: provider_user_id,
                                                    token_id: token_id,
                                                    amount: amount,
                                                    metadata: metadata).data
      end
    end

    def minted_token
      @_minted_token ||= MintedToken.new(@minted_token)
    end
  end
end
