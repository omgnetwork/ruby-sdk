module OmiseGO
  class Transaction < Base
    attributes :id, :idempotency_token, :from, :to, :exchange,
               :metadata, :encrypted_metadata, :status, :created_at

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

        request(client).send('user.list_transactions', body, params: params).data
      end
    end

    def create(from_address:, to_address:, token_id:, amount:, metadata: {}, encrypted_metadata: {})
      request(client).send('transfer', {
                             from_address: from_address,
                             to_address: to_address,
                             token_id: token_id,
                             amount: amount,
                             metadata:  metadata,
                             encrypted_metadata:  encrypted_metadata
                           }, params: params).data
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
