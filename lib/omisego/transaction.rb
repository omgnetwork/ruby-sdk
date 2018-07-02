module OmiseGO
  class Transaction < Base
    attributes :id,
               :idempotency_token,
               :from,
               :to,
               :exchange,
               :metadata,
               :encrypted_metadata,
               :status,
               :created_at

    class << self
      def all(params: {}, client: nil)
        if params[:provider_user_id]
          all_for_user(
            provider_user_id: params[:provider_user_id],
            address: params[:address],
            params: params,
            client: client
          )
        else
          request(client).send('transaction.all', {}, params: params).data
        end
      end

      def all_for_user(provider_user_id:, address: nil, params: {}, client: nil)
        body = {
          provider_user_id: provider_user_id,
          address:          address
        }

        request(client).send('user.get_transactions', body, params: params).data
      end

      def create(from_account_id: nil,
                 from_provider_user_id: nil,
                 from_address: nil,
                 to_account_id: nil,
                 to_provider_user_id: nil,
                 to_address: nil,
                 from_token_id: nil,
                 to_token_id: nil,
                 token_id: nil,
                 from_amount: nil,
                 to_amount: nil,
                 amount: nil,
                 exchange_account_id: nil,
                 exchange_wallet_address: nil,
                 metadata: {},
                 encrypted_metadata: {},
                 idempotency_token:,
                 client: nil)
        request(client).send('transaction.create', from_account_id: from_account_id,
                                                   from_provider_user_id: from_provider_user_id,
                                                   from_address: from_address,
                                                   to_account_id: to_account_id,
                                                   to_provider_user_id: to_provider_user_id,
                                                   to_address: to_address,
                                                   from_token_id: from_token_id,
                                                   to_token_id: to_token_id,
                                                   token_id: token_id,
                                                   from_amount: from_amount,
                                                   to_amount: to_amount,
                                                   amount: amount,
                                                   exchange_account_id: exchange_account_id,
                                                   exchange_wallet_address: exchange_wallet_address,
                                                   metadata: metadata,
                                                   encrypted_metadata: encrypted_metadata,
                                                   idempotency_token: idempotency_token).data
      end
    end

    def from
      @_from ||= TransactionSource.new(@from)
    end

    def to
      @_to ||= TransactionSource.new(@to)
    end

    def exchange
      @_exchange ||= Exchange.new(@exchange)
    end
  end
end
