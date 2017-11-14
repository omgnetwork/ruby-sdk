require 'spec_helper'

module OmiseGO
  RSpec.describe Balance do
    let(:config) do
      OmiseGO::Configuration.new(
        access_key: ENV['ACCESS_KEY'],
        secret_key: ENV['SECRET_KEY'],
        base_url: ENV['KUBERA_URL']
      )
    end
    let(:client) { OmiseGO::Client.new(config) }
    let(:attributes) { { id: '123' } }

    describe '.all' do
      it 'retrieves the list of balances' do
        VCR.use_cassette('balance/all') do
          expect(ENV['PROVIDER_USER_ID']).not_to eq nil
          balances = OmiseGO::Balance.all(
            provider_user_id: ENV['PROVIDER_USER_ID'],
            client: client
          )
          expect(balances).to be_kind_of OmiseGO::List
        end
      end
    end

    describe '.credit' do
      context 'with valid params' do
        it 'retrieves the list of balances' do
          VCR.use_cassette('balance/credit/valid') do
            expect(ENV['PROVIDER_USER_ID']).not_to eq nil
            balances = OmiseGO::Balance.credit(
              provider_user_id: ENV['PROVIDER_USER_ID'],
              symbol: 'OMG',
              amount: 10_000,
              client: client
            )

            expect(balances).to be_kind_of OmiseGO::List
          end
        end
      end
    end
  end
end
