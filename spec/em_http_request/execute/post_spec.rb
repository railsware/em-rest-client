require 'spec_helper'
require_relative 'shared'

RSpec.describe RestClient::EmHttpRequest do
  describe '#execute' do
    include_context :em_http_request_execute

    context 'post' do
      let(:args) do
        {
          method: :post,
          url: 'https://www.example.com',
          headers: {
            'X-Token': 'MyToken'
          },
          payload: payload
        }
      end

      context 'hash payload' do
        let(:payload) do
          {
            name: 'John Doe',
            email: 'john.doe@gmail.com'
          }
        end

        before do
          WebMock.
            stub_request(:post, 'https://www.example.com/').
            with(
              headers: {
                'X-Token' => 'MyToken',
              },
              body: {
                'name' => 'John Doe',
                'email' => 'john.doe@gmail.com'
              }
            ).
            to_return(
              status: 201,
              headers: {
                'Content-Type' => 'text/html'
              },
              body: '<h2>Success</h2>'
            )
        end

        specify do
          expect(subject.code).to eq(201)
        end

        specify do
          expect(subject.headers).to eq(
            content_type: 'text/html',
            content_length: '16'
          )
        end

        specify do
          expect(subject.body).to eq('<h2>Success</h2>')
        end
      end

      context 'json payload' do
        let(:payload) do
          %Q({"name":"John Doe","email":"john.doe@gmail.com"})
        end

        before do
          WebMock.
            stub_request(:post, 'https://www.example.com/').
            with(
              headers: {
                'X-Token' => 'MyToken',
              },
              body: %Q({"name":"John Doe","email":"john.doe@gmail.com"})
            ).
            to_return(
              status: 201,
              headers: {
                'Content-Type' => 'text/html'
              },
              body: '<h2>Success</h2>'
            )
        end

        specify do
          expect(subject.code).to eq(201)
        end

        specify do
          expect(subject.headers).to eq(
            content_type: 'text/html',
            content_length: '16'
          )
        end

        specify do
          expect(subject.body).to eq('<h2>Success</h2>')
        end
      end
    end
  end
end
