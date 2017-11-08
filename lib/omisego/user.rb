module OmiseGO
  class User < Base
    attributes :id, :username, :provider_user_id, :metadata

    class << self
      def login(provider_user_id, client: nil)
        request(client).send('/login', provider_user_id: provider_user_id).data
      end

      def find(provider_user_id, client: nil)
        return ErrorHandler.handle(:nil_id) unless provider_user_id
        request(client).send('/user.get', provider_user_id: provider_user_id).data
      end

      def create(params, client: nil)
        request(client).send('/user.create', params).data
      end

      def update(params, client: nil)
        request(client).send('/user.update', params).data
      end

      def request(client)
        (client || global_client).request
      end
    end

    def login
      login(provider_user_id)
    end

    def update(params)
      params[:provider_user_id] = provider_user_id
      update(params, client)
    end
  end
end
