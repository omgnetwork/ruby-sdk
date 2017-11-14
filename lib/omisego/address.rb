module OmiseGO
  class Address < Base
    attributes :address

    def balances
      @_balances ||= @balances.map do |balance|
        Balance.new(balance)
      end
    end
  end
end
