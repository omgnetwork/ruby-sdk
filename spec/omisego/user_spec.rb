require 'spec_helper'

module OmiseGO
  RSpec.describe Response do
    let(:config) { OmiseGO::Configuration.new }
    let(:client) { OmiseGO::Client.new(config) }
    let(:attributes) { { id: '123' } }
    let(:user) { OmiseGO::User.new(attributes, client) }

    describe '.find' do
      context 'when user exists'
      context 'when user does not exist'
      context 'when passed id is nil'
    end

    describe '.create' do
      context 'when valid parameters'
      context 'when invalid parameters'
    end

    describe '#update' do
      context 'when user does not exist'
      context 'with valid parameters'
      context 'with invalid parameters'
    end
  end
end
