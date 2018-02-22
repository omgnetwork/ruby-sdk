module OmiseGO
  class Transaction < Base
    attributes :id, :idempotency_token, :amount, :minted_token, :from, :to, :status,
               :created_at, :updated_at

    class << self
      def all(params: {}, client: nil)
        request(client).send('transaction.all', {}, params: params).data
      end

      def all_for_user(provider_user_id:, address: nil, params: {}, client: nil)
        body = {
          provider_user_id: provider_user_id,
          address:          address
        }

        request(client).send('user.list_transactions', body, params: params).data
      end
    end
  end
end
