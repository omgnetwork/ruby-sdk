require 'spec_helper'
require 'securerandom'

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
          list = OmiseGO::Balance.all(
            provider_user_id: ENV['PROVIDER_USER_ID'],
            client: client
          )
          expect(list).to be_kind_of OmiseGO::List
          expect(list.first).to be_kind_of OmiseGO::Address
          expect(list.first.balances.first).to be_kind_of OmiseGO::Balance
          expect(list.first.balances.first.minted_token).to be_kind_of OmiseGO::MintedToken
        end
      end
    end

    describe '.credit' do
      context 'with valid params' do
        it "credits the user's balance" do
          VCR.use_cassette('balance/credit/valid') do
            expect(ENV['PROVIDER_USER_ID']).not_to eq nil
            balances = OmiseGO::Balance.credit(
              provider_user_id: ENV['PROVIDER_USER_ID'],
              token_id: 'OMG:123',
              amount: 10_000,
              client: client,
              idempotency_token: SecureRandom.uuid
            )

            expect(balances).to be_kind_of OmiseGO::List
          end
        end
      end
    end

    describe '.debit' do
      context 'with valid params' do
        it "debits the user's balance" do
          VCR.use_cassette('balance/debit/valid') do
            expect(ENV['PROVIDER_USER_ID']).not_to eq nil
            balances = OmiseGO::Balance.debit(
              provider_user_id: ENV['PROVIDER_USER_ID'],
              token_id: 'OMG:123',
              amount: 1000,
              client: client,
              idempotency_token: SecureRandom.uuid
            )

            expect(balances).to be_kind_of OmiseGO::List
          end
        end
      end
    end
  end
end
