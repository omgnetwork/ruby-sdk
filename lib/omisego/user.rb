module OmiseGO
  class User < Base
    attributes :id, :username, :provider_user_id, :metadata

    class << self
      def login(provider_user_id:, client: nil)
        request(client).send('login', provider_user_id: provider_user_id).data
      end

      def find(provider_user_id:, client: nil)
        return ErrorHandler.handle(:nil_id) unless provider_user_id
        request(client).send('user.get', provider_user_id: provider_user_id).data
      end

      def create(provider_user_id:, username:, metadata: {}, client: nil)
        request(client).send('user.create', provider_user_id: provider_user_id,
                                            username: username,
                                            metadata: metadata).data
      end

      def update(provider_user_id:, username:, metadata: {}, client: nil)
        request(client).send('user.update', provider_user_id: provider_user_id,
                                            username: username,
                                            metadata: metadata).data
      end

      def wallets(provider_user_id:, client: nil)
        request(client).send('user.list_wallets', provider_user_id: provider_user_id).data
      end

      def credit(provider_user_id:, user_address: nil, token_id:, amount:, metadata: {},
                 idempotency_token:, account_id:, account_address: nil, client: nil)
        request(client)
          .send('user.credit_wallet', provider_user_id: provider_user_id,
                                      user_address: user_address,
                                      token_id: token_id,
                                      amount: amount,
                                      metadata: metadata,
                                      account_id: account_id,
                                      account_address: account_address,
                                      idempotency_token: idempotency_token).data
      end

      def debit(provider_user_id:, user_address: nil, token_id:, amount:, metadata: {},
                idempotency_token:, account_id:, account_address: nil, client: nil)
        request(client)
          .send('user.debit_wallet', provider_user_id: provider_user_id,
                                     user_address: user_address,
                                     token_id: token_id,
                                     amount: amount,
                                     metadata: metadata,
                                     account_id: account_id,
                                     account_address: account_address,
                                     idempotency_token: idempotency_token).data
      end
    end

    def login(client: nil)
      self.class.login(provider_user_id, client: client)
    end

    def update(username:, metadata: {}, client: nil)
      self.class.update(provider_user_id: provider_user_id,
                        username: username,
                        metadata: metadata,
                        client: client)
    end

    def wallets(client: nil)
      self.class.wallets(provider_user_id: provider_user_id, client: client)
    end

    def credit(token_id:, amount:, metadata: {}, idempotency_token:,
               account_id: nil, account_address: nil, client: nil)
      self.class.credit(provider_user_id: provider_user_id,
                        token_id: token_id,
                        amount: amount,
                        metadata: metadata,
                        account_id: account_id,
                        account_address: account_address,
                        idempotency_token: idempotency_token,
                        client: client)
    end

    def debit(token_id:, amount:, metadata: {}, idempotency_token:,
              account_id: nil, account_address: nil, client: nil)
      self.class.debit(provider_user_id: provider_user_id,
                       token_id: token_id,
                       amount: amount,
                       metadata: metadata,
                       account_id: account_id,
                       account_address: account_address,
                       idempotency_token: idempotency_token,
                       client: client)
    end
  end
end
