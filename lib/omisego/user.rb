module OmiseGO
  class User < Base
    attributes :id, :username, :provider_user_id, :metadata

    class << self
      def find(id)
        call('/user.get', id: id).data
      end

      def create(params)
        call('/user.create', params).data
      end
    end

    def update(params)
      call('/user.update', params).data
    end
  end
end
