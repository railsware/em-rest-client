require 'spec_helper'

RSpec.describe RestClient::EmHttpRequest do

  describe '#build_connection' do
    subject { request.send :build_connection, uri }

    let(:request) { described_class.new(args) }

    let(:uri) { URI.parse('http://example.com') }

    let(:args) do
      {method: :get, url: 'https://www.google.com'}.merge(options)
    end
    let(:options) { {} }

    context 'empty optional args' do
      specify do
        expect(subject).to be_kind_of(EventMachine::HttpConnection)
      end

      specify do
        expect(subject.connopts.connect_timeout).to eq(5)
      end

      specify do
        expect(subject.connopts.inactivity_timeout).to eq(10)
      end
    end

    context 'open_timeout option given' do
      let(:options) { {open_timeout: 30} }

      specify do
        expect(subject.connopts.connect_timeout).to eq(30)
      end

      specify do
        expect(subject.connopts.inactivity_timeout).to eq(10)
      end
    end

    context 'timeout option given' do
      let(:options) { {timeout: 30} }

      specify do
        expect(subject.connopts.connect_timeout).to eq(5)
      end

      specify do
        expect(subject.connopts.inactivity_timeout).to eq(30)
      end
    end

    context 'global proxy option given' do
      before { RestClient.proxy = 'http://john:1234@proxy.example.com:3128' }
      after { RestClient.proxy = nil }

      specify do
        expect(subject.connopts.proxy).to eq(
          host: 'proxy.example.com',
          port: 3128,
          authorization: ['john', '1234']
        )
      end
    end
  end
end
