require 'spec_helper'

module OmiseGO
  RSpec.describe Request do
    let(:config) { OmiseGO::Configuration.new }
    let(:client) { OmiseGO::Client.new(config) }
    let(:request) { OmiseGO::Request.new(client) }
    let(:conn) { Faraday.new(url: 'https://example.com') }

    describe '#call' do
      before do
        expect(conn).to receive(:post)
          .and_return(double(:response, status: 200, body: '{}'))
      end

      it 'posts the request' do
        request.call(path: '/test', body: {}, conn: conn)
      end

      it 'returns a Response object' do
        response = request.call(path: '/test', body: {}, conn: conn)
        expect(response).to be_kind_of OmiseGO::Response
      end
    end
  end
end
