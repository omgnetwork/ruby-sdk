module OmiseGO
  class Wallet < Base
    attributes :address, :balances, :socket_topic, :name, :identifier,
               :metadata, :encrypted_metadata, :user_id, :user, :account_id,
               :account, :created_at, :updated_at

    class << self
      def all(provider_user_id:, client: nil)
        request(client).send('user.list_wallets', provider_user_id: provider_user_id).data
      end

      def credit(provider_user_id:, token_id:, amount:, metadata: {}, user_address: nil,
                 encrypted_metadata: {}, idempotency_token:, account_id:, account_address: nil,
                 client: nil)
        request(client)
          .send('user.credit_wallet', provider_user_id: provider_user_id,
                                      user_address: user_address,
                                      token_id: token_id,
                                      amount: amount,
                                      metadata: metadata,
                                      encrypted_metadata: encrypted_metadata,
                                      account_id: account_id,
                                      account_address: account_address,
                                      idempotency_token: idempotency_token).data
      end

      def debit(provider_user_id:, user_address: nil, token_id:, amount:, metadata: {},
                encrypted_metadata: {}, idempotency_token:, account_id:, account_address: nil,
                client: nil)
        request(client)
          .send('user.debit_wallet', provider_user_id: provider_user_id,
                                     user_address: user_address,
                                     token_id: token_id,
                                     amount: amount,
                                     metadata: metadata,
                                     encrypted_metadata: encrypted_metadata,
                                     account_id: account_id,
                                     account_address: account_address,
                                     idempotency_token: idempotency_token).data
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
