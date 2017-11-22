module OmiseGO
  class Address < Base
    attributes :address, :balances

    def balances
      @_balances ||= @balances.map do |balance|
        Balance.new(balance)
      end
    end
  end
end
