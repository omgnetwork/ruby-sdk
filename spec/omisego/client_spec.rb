require 'spec_helper'

module OmiseGO
  RSpec.describe Client do
    describe '#initialize' do
      context 'with overriding options' do
        it 'overrides the values in the configuration' do
          config = OmiseGO::Client.new(access_key: 'access_key',
                                       secret_key: 'secret_key').config
          expect(config.access_key).to eq('access_key')
          expect(config.secret_key).to eq('secret_key')
          expect(config.api_version).to eq('1')
          expect(config.base_url).to eq('https://example.com')
          expect(config.auth_scheme).to eq('OMGServer')
        end
      end

      context 'without the options argument' do
        it 'loads the default configuration' do
          config = OmiseGO::Client.new.config
          expect(config.access_key).to eq(nil)
          expect(config.secret_key).to eq(nil)
          expect(config.api_version).to eq('1')
          expect(config.base_url).to eq('https://example.com')
          expect(config.auth_scheme).to eq('OMGServer')
        end
      end
    end
  end
end
