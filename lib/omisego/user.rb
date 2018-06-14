module OmiseGO
  class User < Base
    attributes :id, :username, :provider_user_id, :metadata, :encrypted_metadata

    class << self
      def login(provider_user_id:, client: nil)
        request(client).send('login', provider_user_id: provider_user_id).data
      end

      def find(provider_user_id:, client: nil)
        return ErrorHandler.handle(:nil_id) unless provider_user_id
        request(client).send('user.get', provider_user_id: provider_user_id).data
      end

      def create(provider_user_id:, username:, metadata: {},
                 encrypted_metadata: {}, client: nil)
        request(client).send('user.create', provider_user_id: provider_user_id,
                                            username: username,
                                            metadata: metadata,
                                            encrypted_metadata: encrypted_metadata).data
      end

      def update(provider_user_id:, username:, metadata: {},
                 encrypted_metadata: {}, client: nil)
        request(client).send('user.update', provider_user_id: provider_user_id,
                                            username: username,
                                            metadata: metadata,
                                            encrypted_metadata: encrypted_metadata).data
      end

      def wallets(provider_user_id:, client: nil)
        request(client).send('user.list_wallets', provider_user_id: provider_user_id).data
      end
    end

    def login(client: nil)
      self.class.login(provider_user_id, client: client)
    end

    def update(username:, metadata: {}, encrypted_metadata: {}, client: nil)
      self.class.update(provider_user_id: provider_user_id,
                        username: username,
                        metadata: metadata,
                        encrypted_metadata: encrypted_metadata,
                        client: client)
    end

    def wallets(client: nil)
      self.class.wallets(provider_user_id: provider_user_id, client: client)
    end
  end
end
