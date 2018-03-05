require 'spec_helper'

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
          expect(transactions.data.count).to eq 10

          pagination = transactions.pagination
          expect(pagination).to be_kind_of OmiseGO::Pagination
          expect(pagination.per_page).to eq 10
          expect(pagination.current_page).to eq 1
          expect(pagination.first_page?).to eq true
          expect(pagination.last_page?).to eq false

          transaction = transactions.data.first
          expect(transaction).to be_kind_of OmiseGO::Transaction

          expect(transaction.from).to be_kind_of OmiseGO::TransactionSource
          expect(transaction.to).to be_kind_of OmiseGO::TransactionSource
          expect(transaction.exchange).to be_kind_of OmiseGO::Exchange
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
          expect(transactions.data.count).to eq 10
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
  end
end
