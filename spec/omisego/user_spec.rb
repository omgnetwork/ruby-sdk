require 'spec_helper'
require 'logger'

module OmiseGO
  RSpec.describe User do
    let(:config) do
      OmiseGO::Configuration.new(
        access_key: ENV['ACCESS_KEY'],
        secret_key: ENV['SECRET_KEY'],
        base_url:   ENV['EWALLET_URL']
      )
    end
    let(:client) { OmiseGO::Client.new(config) }
    let(:attributes) { { id: '123' } }

    describe '.login' do
      context 'when user exists' do
        it 'retrieves the user' do
          VCR.use_cassette('user/login/existing') do
            expect(ENV['PROVIDER_USER_ID']).not_to eq nil
            auth_token = OmiseGO::User.login(
              provider_user_id: ENV['PROVIDER_USER_ID'],
              client: client
            )
            expect(auth_token).to be_kind_of OmiseGO::AuthenticationToken
            expect(auth_token.authentication_token).not_to eq nil
          end
        end

        context 'with logging' do
          let(:logger) { Logger.new(STDOUT) }
          let(:config) do
            OmiseGO::Configuration.new(
              access_key: ENV['ACCESS_KEY'],
              secret_key: ENV['SECRET_KEY'],
              base_url: ENV['EWALLET_URL'],
              logger: logger
            )
          end

          it 'logs the request' do
            VCR.use_cassette('user/login/existing') do
              expect(logger).to receive(:info) do |log_line|
                expect(log_line).to include("[OmiseGO] Request: POST login\n")
              end
              expect(logger).to receive(:info) do |log_line|
                expect(log_line).to include("[OmiseGO] Response: HTTP/200\n")
              end
              OmiseGO::User.login(
                provider_user_id: ENV['PROVIDER_USER_ID'],
                client: client
              )
            end
          end
        end
      end

      context 'when user does not exist' do
        it 'returns a not found error' do
          VCR.use_cassette('user/login/not_existing') do
            error = OmiseGO::User.login(
              provider_user_id: '123',
              client: client
            )
            expect(error).to be_kind_of OmiseGO::Error
            expect(error.code).to eq('user:provider_user_id_not_found')
            expect(error.description).to eq(
              'There is no user corresponding to the provided provider_user_id'
            )
          end
        end
      end
    end

    describe '.find' do
      context 'when user exists' do
        it 'retrieves the user' do
          VCR.use_cassette('user/find/existing') do
            expect(ENV['PROVIDER_USER_ID']).not_to eq nil
            user = OmiseGO::User.find(
              provider_user_id: ENV['PROVIDER_USER_ID'],
              client: client
            )
            expect(user).to be_kind_of OmiseGO::User
            expect(user.provider_user_id).to eq ENV['PROVIDER_USER_ID']
          end
        end
      end

      context 'when user does not exist' do
        it 'returns a not found error' do
          VCR.use_cassette('user/find/not_existing') do
            error = OmiseGO::User.find(
              provider_user_id: '123',
              client: client
            )
            expect(error).to be_kind_of OmiseGO::Error
            expect(error.code).to eq 'user:provider_user_id_not_found'
            expect(error.description).to eq(
              'There is no user corresponding to the provided provider_user_id'
            )
          end
        end
      end

      context 'when passed id is nil' do
        it 'returns a not found error' do
          VCR.use_cassette('user/find/nil') do
            error = OmiseGO::User.find(
              provider_user_id: nil,
              client: client
            )
            expect(error).to be_kind_of OmiseGO::Error
            expect(error.code).to eq 'user:nil_id'
            expect(error.description).to eq('The given ID was nil.')
          end
        end
      end
    end

    describe '.create' do
      context 'when valid parameters' do
        it 'creates and retrieves the user' do
          VCR.use_cassette('user/create/valid') do
            email = 'john2@doe.com'

            user = OmiseGO::User.create(
              provider_user_id: 'userOMGShopAPITest02',
              username: email,
              metadata: {
                first_name: 'John',
                last_name: 'Doe'
              },
              client: client
            )
            expect(user).to be_kind_of OmiseGO::User
            expect(user.username).to eq email
          end
        end
      end

      context 'when invalid parameters' do
        it 'gets an invalid parameter error' do
          VCR.use_cassette('user/create/invalid') do
            error = OmiseGO::User.create(
              provider_user_id: 'userOMGShopAPITest02',
              username: 'user01',
              metadata: {
                first_name: 'John',
                last_name: 'Denizet'
              },
              client: client
            )
            expect(error).to be_kind_of OmiseGO::Error
            expect(error.code).to eq 'client:invalid_parameter'
          end
        end
      end
    end

    describe '.update' do
      context 'when user does not exist' do
        it 'returns an error' do
          VCR.use_cassette('user/update/not_existing') do
            error = OmiseGO::User.update(
              provider_user_id: 'fake',
              username: 'jane@doe.com',
              metadata: {
                first_name: 'Jane',
                last_name: 'Denizet'
              },
              client: client
            )

            expect(error).to be_kind_of OmiseGO::Error
            expect(error.description).to eq(
              'There is no user corresponding to the provided provider_user_id'
            )
          end
        end
      end

      context 'with valid parameters' do
        it 'creates and retrieves the user' do
          VCR.use_cassette('user/update/valid') do
            user = OmiseGO::User.update(
              provider_user_id: 'userOMGShopAPITest',
              username: 'jane@doe.com',
              metadata: {
                first_name: 'Jane',
                last_name: 'Doe'
              },
              client: client
            )

            expect(user).to be_kind_of OmiseGO::User
            expect(user.username).to eq 'jane@doe.com'
          end
        end
      end

      context 'with invalid parameters' do
        it 'returns an invalid parameter error' do
          VCR.use_cassette('user/update/invalid') do
            error = OmiseGO::User.update(
              provider_user_id: 'userOMGShopAPITest',
              username: '',
              metadata: {
                first_name: 'Jane',
                last_name: 'Doe'
              },
              client: client
            )

            expect(error).to be_kind_of OmiseGO::Error
            expect(error.description).to eq(
              "Invalid parameter provided. `username` can't be blank."
            )
          end
        end
      end
    end
  end
end
