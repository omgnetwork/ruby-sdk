require 'spec_helper'
require 'securerandom'

module OmiseGO
  RSpec.describe Transaction do
    let(:config) do
      OmiseGO::Configuration.new(
        access_key: ENV['ACCESS_KEY'],
        secret_key: ENV['SECRET_KEY'],
        base_url: ENV['EWALLET_URL']
      )
    end
    let(:client) { OmiseGO::Client.new(config) }

    describe '.all' do
      it 'retrieves all the transactions paginated' do
        VCR.use_cassette('transaction/all/paginated') do
          transactions = OmiseGO::Transaction.all(client: client)

          expect(transactions).to be_kind_of OmiseGO::List
          expect(transactions.data.count).to be > 1

          pagination = transactions.pagination
          expect(pagination).to be_kind_of OmiseGO::Pagination
          expect(pagination.per_page).to eq 10
          expect(pagination.current_page).to eq 1
          expect(pagination.first_page?).to eq true

          transaction = transactions.data.first
          expect(transaction).to be_kind_of OmiseGO::Transaction

          expect(transaction.from).to be_kind_of OmiseGO::TransactionSource
          expect(transaction.to).to be_kind_of OmiseGO::TransactionSource
          expect(transaction.exchange).to be_kind_of OmiseGO::Exchange
          expect(transaction.metadata).to eq({})
        end
      end

      it 'retrieves all the transactions' do
        VCR.use_cassette('transaction/all/custom') do
          transactions = OmiseGO::Transaction.all(
            params: {
              page: 2,
              per_page: 2,
              sort_by: 'created_at',
              sort_dir: 'desc',
              search_params: {
                status: 'confirmed'
              }
            },
            client: client
          )

          expect(transactions).to be_kind_of OmiseGO::List
          expect(transactions.data.first).to be_kind_of OmiseGO::Transaction
          expect(transactions.data.count).to eq 2
          expect(transactions.data.first.created_at).to be > transactions.data.last.created_at
        end
      end

      it 'retrieves all the transactions for a specific user' do
        VCR.use_cassette('transaction/all_for_user/paginated') do
          transactions = OmiseGO::Transaction.all(
            params: {
              provider_user_id: ENV['PROVIDER_USER_ID'],
              page: 2,
              per_page: 2,
              sort_by: 'created_at',
              sort_dir: 'desc',
              search_params: {
                status: 'confirmed'
              }
            },
            client: client
          )

          expect(transactions).to be_kind_of OmiseGO::List
          expect(transactions.data.first).to be_kind_of OmiseGO::Transaction
          expect(transactions.data.count).to be > 1
        end
      end
    end

    describe '.all_for_user' do
      it 'retrieves all the transactions paginated' do
        VCR.use_cassette('transaction/all_for_user/paginated') do
          transactions = OmiseGO::Transaction.all_for_user(
            provider_user_id: ENV['PROVIDER_USER_ID'],
            client: client
          )

          expect(transactions).to be_kind_of OmiseGO::List
          expect(transactions.data.first).to be_kind_of OmiseGO::Transaction
          expect(transactions.data.count).to be > 1
        end
      end

      it 'retrieves all the transactions' do
        VCR.use_cassette('transaction/all_for_user/custom') do
          transactions = OmiseGO::Transaction.all_for_user(
            provider_user_id: ENV['PROVIDER_USER_ID'],
            params: {
              page: 2,
              per_page: 2,
              sort_by: 'created_at',
              sort_dir: 'desc',
              search_params: {
                status: 'confirmed'
              }
            },
            client: client
          )

          expect(transactions).to be_kind_of OmiseGO::List
          expect(transactions.data.first).to be_kind_of OmiseGO::Transaction
          expect(transactions.data.count).to eq 2
          expect(transactions.data.first.created_at).to be > transactions.data.last.created_at
        end
      end
    end

    describe '/create' do
      it 'creates a simple transaction' do
        VCR.use_cassette('transaction/create/simple') do
          transaction = OmiseGO::Transaction.create(
            from_account_id: ENV['ACCOUNT_ID'],
            to_provider_user_id: ENV['PROVIDER_USER_ID'],
            amount: 1,
            token_id: ENV['TOKEN_ID'],
            idempotency_token: SecureRandom.uuid,
            client: client
          )

          expect(transaction).to be_kind_of OmiseGO::Transaction
        end
      end

      it 'creates an exchange transaction' do
        VCR.use_cassette('transaction/create/simple') do
          transaction = OmiseGO::Transaction.create(
            from_account_id: ENV['ACCOUNT_ID'],
            to_provider_user_id: ENV['PROVIDER_USER_ID'],
            from_amount: 1,
            from_token_id: ENV['TOKEN_ID'],
            to_token_id: ENV['TOKEN_ID'],
            idempotency_token: SecureRandom.uuid,
            client: client
          )

          expect(transaction).to be_kind_of OmiseGO::Transaction
        end
      end
    end
  end
end
