require 'spec_helper'

RSpec.describe OmiseGO::Configuration do
  describe 'attributes' do
    describe 'pre-set ENV variables' do
      it 'uses the defined ENV variables' do
        ENV['OMISEGO_ACCESS_KEY'] = 'access'
        ENV['OMISEGO_SECRET_KEY'] = 'secret'
        ENV['OMISEGO_BASE_URL'] = 'https://example.com'

        config = OmiseGO::Configuration.new
        expect(config.access_key).to eq('access')
        expect(config.secret_key).to eq('secret')
        expect(config.base_url).to eq('https://example.com')

        ENV.delete('OMISEGO_ACCESS_KEY')
        ENV.delete('OMISEGO_SECRET_KEY')
        ENV.delete('OMISEGO_BASE_URL')
      end
    end

    it 'can set value' do
      config = OmiseGO::Configuration.new
      config.access_key = 'access_key'
      expect(config.access_key).to eq('access_key')
    end
  end

  describe '#initialize' do
    it 'sets all the values to their defaults' do
      config = OmiseGO::Configuration.new
      expect(config.access_key).to eq(nil)
      expect(config.secret_key).to eq(nil)
      expect(config.api_version).to eq('1')
      expect(config.base_url).to eq(nil)
    end

    context 'with overriding options' do
      it 'uses the values passed as options' do
        config = OmiseGO::Configuration.new(access_key: '123')
        expect(config.access_key).to eq('123')
        expect(config.secret_key).to eq(nil)
        expect(config.api_version).to eq('1')
        expect(config.base_url).to eq(nil)
      end
    end
  end

  describe '#[]' do
    it 'returns the request value' do
      expect(OmiseGO::Configuration.new[:base_url]).to eq(nil)
    end
  end

  describe '#to_hash' do
    it 'returns the configuration as a hash' do
      expect(OmiseGO::Configuration.new.to_hash).to eq(
        access_key: nil,
        secret_key: nil,
        base_url: nil
      )
    end
  end

  describe '#merge' do
    it 'merges the given options' do
      config = OmiseGO::Configuration.new
      config.merge(access_key: 'access_key')
      expect(config.access_key).to eq('access_key')
    end
  end
end
