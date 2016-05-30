require 'spec_helper'
require_relative 'shared'

RSpec.describe RestClient::EmHttpRequest do
  describe '#execute' do
    include_context :em_http_request_execute

    context 'head' do
      let(:args) do
        {
          method: :head,
          url: 'https://john:123@www.example.com?key=value',
          headers: {
            'X-Token': 'MyToken'
          }
        }
      end

      before do
        WebMock.
          stub_request(:head, 'https://www.example.com/').
          with(
            headers: {
              'Authorization' => 'Basic am9objoxMjM=',
              'X-Token' => 'MyToken',
            },
            query: {'key' => 'value'}
          ).
          to_return(
            status: 200,
            headers: {
            },
            body: ''
          )
      end

      specify do
        expect(subject).to be_kind_of(String)
      end

      specify do
        expect(subject.code).to eq(200)
      end

      specify do
        expect(subject.headers).to eq(
          content_length: '0'
        )
      end

      specify do
        expect(subject.body).to eq('')
      end
    end
  end
end
