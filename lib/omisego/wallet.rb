module OmiseGO
  class Wallet < Base
    attributes :address, :balances, :socket_topic, :name, :identifier,
               :metadata, :encrypted_metadata, :user_id, :user, :account_id,
               :account, :created_at, :updated_at

    class << self
      def all(provider_user_id:, client: nil)
        request(client).send('user.get_wallets', provider_user_id: provider_user_id).data
      end

      def all_for_account(account_id:, client: nil)
        request(client).send('account.get_wallets', id: account_id).data
      end

      def credit(provider_user_id:, token_id:, amount:, metadata: {}, user_address: nil,
                 encrypted_metadata: {}, idempotency_token:, account_id:, account_address: nil,
                 client: nil)
        params = { to_provider_user_id: provider_user_id,
                   to_address: user_address,
                   from_account_id: account_id,
                   from_address: account_address,
                   token_id: token_id,
                   amount: amount,
                   metadata: metadata,
                   encrypted_metadata: encrypted_metadata,
                   account_address: account_address,
                   idempotency_token: idempotency_token }
        request(client).send('transaction.create', params).data
      end

      def debit(provider_user_id:, user_address: nil, token_id:, amount:, metadata: {},
                encrypted_metadata: {}, idempotency_token:, account_id:, account_address: nil,
                client: nil)
        params = { from_provider_user_id: provider_user_id,
                   from_address: user_address,
                   to_account_id: account_id,
                   to_address: account_address,
                   token_id: token_id,
                   amount: amount,
                   metadata: metadata,
                   encrypted_metadata: encrypted_metadata,
                   account_address: account_address,
                   idempotency_token: idempotency_token }
        request(client).send('transaction.create', params).data
      end
    end

    def user
      @_user ||= User.new(@user)
    end

    def account
      @_account ||= Account.new(@account)
    end

    def balances
      @_balances ||= @balances.map do |balance|
        Balance.new(balance)
      end
    end
  end
end
