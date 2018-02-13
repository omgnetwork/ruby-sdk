require 'spec_helper'

module OmiseGO
  RSpec.describe Request do
    let(:config) { OmiseGO::Configuration.new }
    let(:client) { OmiseGO::Client.new(config) }
    let(:request) { OmiseGO::Request.new(client) }
    let(:conn) { Faraday.new(url: ENV['EWALLET_URL']) }

    describe '#send' do
      context 'valid json response' do
        before do
          expect(conn).to receive(:post)
            .and_return(double(:response, status: 200, headers: {}, body: '{}'))
        end

        it 'posts the request' do
          request.send('/test', {}, conn: conn)
        end

        it 'returns a Response object' do
          response = request.send('/test', {}, conn: conn)
          expect(response).to be_kind_of OmiseGO::Response
        end
      end

      context 'invalid json response' do
        before do
          expect(conn).to receive(:post).and_raise(JSON::ParserError, 'Error')
        end

        it 'returns an error' do
          error = request.send('/test', {}, conn: conn).data
          expect(error).to be_kind_of OmiseGO::Error
          expect(error.code).to eq 'json_parsing_error'
          expect(error.description).to eq 'The JSON received from the server ' \
                                          'could not be parsed: Error'
        end
      end

      context 'invalid status code' do
        before do
          expect(conn).to receive(:post)
            .and_return(double(:response, status: 400, headers: {}, body: '{}'))
        end

        it 'returns a Response object' do
          error = request.send('/test', {}, conn: conn).data
          expect(error).to be_kind_of OmiseGO::Error
          expect(error.code).to eq 'invalid_status_code'
          expect(error.description).to eq 'The server returned an invalid status code: 400'
        end
      end

      context 'failed connection' do
        before do
          expect(conn).to receive(:post).and_raise(Faraday::Error::ConnectionFailed, 'Test')
        end

        it 'returns an error' do
          error = request.send('/test', {}, conn: conn).data
          expect(error).to be_kind_of OmiseGO::Error
          expect(error.code).to eq 'connection_failed'
          expect(error.description).to eq 'Test'
        end
      end
    end
  end
end
