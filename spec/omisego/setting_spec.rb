require 'spec_helper'

module OmiseGO
  RSpec.describe Setting do
    let(:config) do
      OmiseGO::Configuration.new(
        access_key: ENV['ACCESS_KEY'],
        secret_key: ENV['SECRET_KEY'],
        base_url: ENV['EWALLET_URL']
      )
    end
    let(:client) { OmiseGO::Client.new(config) }

    describe '.all' do
      it 'retrieves all the settings' do
        VCR.use_cassette('setting/all') do
          settings = OmiseGO::Setting.all(client: client)

          expect(settings).to be_kind_of OmiseGO::Setting
          expect(settings.tokens.first).to be_kind_of OmiseGO::Token
          expect(settings.tokens.last).to be_kind_of OmiseGO::Token
        end
      end
    end
  end
end
