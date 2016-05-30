require 'spec_helper'

RSpec.describe RestClient::Request do

  describe '.execute' do
    let(:args) { {} }
    let(:request) { double('REQUEST') }

    subject { described_class.execute(args) }

    context 'default global adapter' do
      context 'no adapter given' do
        specify do
          expect(RestClient::Request).to receive(:new).with(args).and_return(request)
          expect(request).to receive(:execute)
          subject
        end
      end

      context 'net_http adapter' do
        let(:args) { {adapter: :net_http} }

        specify do
          expect(RestClient::Request).to receive(:new).with(args).and_return(request)
          expect(request).to receive(:execute)
          subject
        end
      end

      context 'em_http adapter' do
        let(:args) { {adapter: :em_http} }

        specify do
          expect(RestClient::EmHttpRequest).to receive(:new).with(args).and_return(request)
          expect(request).to receive(:execute)
          subject
        end
      end
    end

    context 'global em_http adapter' do
      before { RestClient.adapter = :em_http }
      after { RestClient.adapter = nil }

      context 'no adapter given' do
        specify do
          expect(RestClient::EmHttpRequest).to receive(:new).with(args).and_return(request)
          expect(request).to receive(:execute)
          subject
        end
      end

      context 'net_http adapter' do
        let(:args) { {adapter: :net_http} }

        specify do
          expect(RestClient::Request).to receive(:new).with(args).and_return(request)
          expect(request).to receive(:execute)
          subject
        end
      end

      context 'em_http adapter' do
        let(:args) { {adapter: :em_http} }

        specify do
          expect(RestClient::EmHttpRequest).to receive(:new).with(args).and_return(request)
          expect(request).to receive(:execute)
          subject
        end
      end
    end
  end

end
