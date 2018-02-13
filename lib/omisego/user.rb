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
    end

    def login
      login(provider_user_id)
    end

    def update(username:, metadata: {}, client: nil)
      update({
               provider_user_id: provider_user_id,
               username: username,
               metadata: metadata
             }, client)
    end
  end
end
