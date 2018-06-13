module OmiseGO
  class Balance < Base
    attributes :amount, :token

    def token
      @_token ||= Token.new(@token)
    end
  end
end
