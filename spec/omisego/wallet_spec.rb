require 'spec_helper'
require 'securerandom'

module OmiseGO
  RSpec.describe Wallet do
    let(:config) do
      OmiseGO::Configuration.new(
        access_key: ENV['ACCESS_KEY'],
        secret_key: ENV['SECRET_KEY'],
        base_url: ENV['EWALLET_URL']
      )
    end
    let(:client) { OmiseGO::Client.new(config) }
    let(:attributes) { { id: '123' } }

    describe '.all' do
      it 'retrieves the list of wallets' do
        VCR.use_cassette('wallet/all') do
          expect(ENV['PROVIDER_USER_ID']).not_to eq nil
          list = OmiseGO::Wallet.all(
            provider_user_id: ENV['PROVIDER_USER_ID'],
            client: client
          )
          expect(list).to be_kind_of OmiseGO::List
          expect(list.first).to be_kind_of OmiseGO::Wallet
          expect(list.first.balances.first).to be_kind_of OmiseGO::Balance
          expect(list.first.balances.first.token).to be_kind_of OmiseGO::Token
        end
      end
    end

    describe '.credit' do
      context 'with valid params' do
        it "credits the user's wallet" do
          VCR.use_cassette('wallet/credit/valid') do
            expect(ENV['PROVIDER_USER_ID']).not_to eq nil
            wallets = OmiseGO::Wallet.credit(
              provider_user_id: ENV['PROVIDER_USER_ID'],
              token_id: ENV['TOKEN_ID'],
              amount: 10_000,
              client: client,
              idempotency_token: SecureRandom.uuid
            )

            expect(wallets).to be_kind_of OmiseGO::List
            address = wallets.first
            expect(address).to be_kind_of OmiseGO::Wallet
          end
        end
      end

      context 'with optional params account_id and burn_wallet_identifier' do
        it "credits the user's wallet" do
          VCR.use_cassette('wallet/credit/valid_optional') do
            expect(ENV['PROVIDER_USER_ID']).not_to eq nil
            wallets = OmiseGO::Wallet.credit(
              account_id: ENV['ACCOUNT_ID'],
              burn_wallet_identifier: 'burn',
              provider_user_id: ENV['PROVIDER_USER_ID'],
              token_id: ENV['TOKEN_ID'],
              amount: 10_000,
              client: client,
              idempotency_token: SecureRandom.uuid
            )

            expect(wallets).to be_kind_of OmiseGO::List
          end
        end
      end
    end

    describe '.debit' do
      context 'with valid params' do
        it "debits the user's wallet" do
          VCR.use_cassette('wallet/debit/valid') do
            expect(ENV['PROVIDER_USER_ID']).not_to eq nil
            wallets = OmiseGO::Wallet.debit(
              provider_user_id: ENV['PROVIDER_USER_ID'],
              token_id: ENV['TOKEN_ID'],
              amount: 1000,
              client: client,
              idempotency_token: SecureRandom.uuid
            )

            expect(wallets).to be_kind_of OmiseGO::List
          end
        end
      end

      context 'with optional params account_id and burn_wallet_identifier' do
        it "debit/s the user's wallet" do
          VCR.use_cassette('wallet/debit/valid_optional') do
            expect(ENV['PROVIDER_USER_ID']).not_to eq nil
            wallets = OmiseGO::Wallet.debit(
              account_id: ENV['ACCOUNT_ID'],
              burn_wallet_identifier: 'burn',
              provider_user_id: ENV['PROVIDER_USER_ID'],
              token_id: ENV['TOKEN_ID'],
              amount: 10_000,
              client: client,
              idempotency_token: SecureRandom.uuid
            )

            expect(wallets).to be_kind_of OmiseGO::List
          end
        end
      end
    end
  end
end
