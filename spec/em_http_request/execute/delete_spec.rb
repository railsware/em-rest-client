require 'spec_helper'
require_relative 'shared'

RSpec.describe RestClient::EmHttpRequest do
  describe '#execute' do
    include_context :em_http_request_execute

    context 'get' do
      let(:args) do
        {
          method: :delete,
          url: 'https://john:123@www.example.com?key=value',
          headers: {
            'X-Token': 'MyToken'
          }
        }
      end

      before do
        WebMock.
          stub_request(:delete, 'https://www.example.com/').
          with(
            headers: {
              'Authorization' => 'Basic am9objoxMjM=',
              'X-Token' => 'MyToken',
            },
            query: {'key' => 'value'}
          ).
          to_return(
            status: 202,
            headers: {
              'Content-Type' => 'text/html'
            },
            body: '<h2>Done</h2>'
          )
      end

      specify do
        expect(subject).to be_kind_of(String)
      end

      specify do
        expect(subject.code).to eq(202)
      end

      specify do
        expect(subject.headers).to eq(
          content_type: 'text/html',
          content_length: '13'
        )
      end

      specify do
        expect(subject.body).to eq('<h2>Done</h2>')
      end
    end
  end
end
