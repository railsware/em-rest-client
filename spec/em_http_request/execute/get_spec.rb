require 'spec_helper'
require_relative 'shared'

RSpec.describe RestClient::EmHttpRequest do
  describe '#execute' do
    include_context :em_http_request_execute

    context 'get' do
      context 'general' do
        let(:args) do
          {
            method: :get,
            url: 'https://john:123@www.example.com?key=value',
            headers: {
              'X-Token': 'MyToken'
            }
          }
        end

        before do
          WebMock.
            stub_request(:get, 'https://www.example.com/').
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
                'Content-Type' => 'text/html'
              },
              body: '<h2>Hello World</h2>'
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
            content_type: 'text/html',
            content_length: '20'
          )
        end

        specify do
          expect(subject.body).to eq('<h2>Hello World</h2>')
        end
      end

      context 'header params' do
        let(:args) do
          {
            method: :get,
            url: 'https://www.example.com',
            headers: {
              'X-Token': 'MyToken',
              params: {key: 'value'}
            }
          }
        end

        before do
          WebMock.
            stub_request(:get, 'https://www.example.com/').
            with(
              headers: {
                'X-Token' => 'MyToken'
              },
              query: {'key' => 'value'}
            ).
            to_return(
              status: 200,
              headers: {
                'Content-Type' => 'text/html'
              },
              body: '<h2>Hello World</h2>'
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
            content_type: 'text/html',
            content_length: '20'
          )
        end

        specify do
          expect(subject.body).to eq('<h2>Hello World</h2>')
        end
      end

      context 'max_redirects' do
        let(:args) do
          {
            method: :get,
            url: 'https://www1.example.com',
            max_redirects: max_redirects
          }
        end

        before do
          WebMock.
            stub_request(:get, 'https://www1.example.com/').
            to_return(
              status: 301,
              headers: {
                'Location' => 'https://www2.example.com/',
                'Content-Type' => 'text/html'
              },
              body: '<h2>Moved 301</h2>'
            )
          WebMock.
            stub_request(:get, 'https://www2.example.com/').
            to_return(
              status: 302,
              headers: {
                'Location' => 'https://www3.example.com/',
                'Content-Type' => 'text/html'
              },
              body: '<h2>Moved 302</h2>'
            )
          WebMock.
            stub_request(:get, 'https://www3.example.com/').
            to_return(
              status: 200,
              headers: {
                'Content-Type' => 'text/html',
                'X-Token' => 'MyToken'
              },
              body: '<h2>SUCCESS</h2>'
            )
        end

        context '1' do
          let(:max_redirects) { 1 }

          specify do
            case RestClient.major_version
            when 1
              expect { subject }.to raise_error(RestClient::MaxRedirectsReached)
            when 2
              expect { subject }.to raise_error(RestClient::Found)
            end
          end
        end

        context '2' do
          let(:max_redirects) { 2 }

          specify do
            expect(subject.code).to eq(200)
          end

          specify do
            expect(subject.headers).to eq(
              content_type: 'text/html',
              x_token: 'MyToken'
            )
          end

          specify do
            expect(subject.body).to eq('<h2>SUCCESS</h2>')
          end
        end
      end

      context 'cookies' do
        let(:args) do
          {
            method: :get,
            url: 'https://www.example.com',
            cookies: {
              old_session_id: '1000',
              old_session_token: 'QWERTY'
            }
          }
        end

        before do
          WebMock.
            stub_request(:get, 'https://www.example.com/').
            with(
              headers: {
                'Cookie' => 'old_session_id=1000; old_session_token=QWERTY'
              }
            ).to_return(
              status: 200,
              headers: {
                'Set-Cookie' => 'new_session_id=2000',
                'Content-Type' => 'text/html'
              },
              body: '<h2>COOKIES</h2>'
            )
        end

        specify do
          expect(subject.code).to eq(200)
        end

        specify do
          expect(subject.headers).to eq(
            content_type: 'text/html',
            content_length: '16',
            set_cookie: ['new_session_id=2000']
          )
        end

        specify do
          expect(subject.cookies).to include(
            'new_session_id' => '2000'
          )
        end

        specify do
          expect(subject.body).to eq('<h2>COOKIES</h2>')
        end
      end

      context 'gzip decoding' do
        let(:args) do
          {
            method: :get,
            url: 'https://www.example.com'
          }
        end

        before do
          WebMock.
            stub_request(:get, 'https://www.example.com/').
            with(
              headers: {
                'Accept' => accept_header,
                'Accept-Encoding' => 'gzip, deflate'
              }
            ).to_return(
              status: 200,
              headers: {
                'Content-Encoding' => 'gzip',
                'Content-Type' => 'text/html'
              },
              body: "\u001F\x8B\b\bx\x97LW\u0000\u0003data\u0000\xB3\xC90\xB2\xF3H\xCD\xC9\xC9W\b\xCF/\xCAI\xB1\xD1\a\xF2\xB9\u0000\x81\xFA\x9CD\u0015\u0000\u0000\u0000"
            )
        end

        specify do
          expect(subject.code).to eq(200)
        end

        specify do
          expect(subject.headers).to eq(
            content_encoding: 'gzip',
            content_type: 'text/html',
            content_length: '44'
          )
        end

        specify do
          expect(subject.body).to eq("<h2>Hello World</h2>\n")
        end
      end

      context 'deflate decoding' do
        let(:args) do
          {
            method: :get,
            url: 'https://www.example.com'
          }
        end

        before do
          WebMock.
            stub_request(:get, 'https://www.example.com/').
            with(
              headers: {
                'Accept' => accept_header,
                'Accept-Encoding'=>'gzip, deflate'
              }
            ).to_return(
              status: 200,
              headers: {
                'Content-Encoding' => 'deflate',
                'Content-Type' => 'text/html'
              },
              body: "x\x9C\xB3\xC90\xB2\xF3H\xCD\xC9\xC9W\b\xCF/\xCAI\xB1\xD1\a\xF2\xB9\u0000J\xEA\u0006~"
            )
        end

        specify do
          expect(subject.code).to eq(200)
        end

        specify do
          expect(subject.headers).to eq(
            content_encoding: 'deflate',
            content_type: 'text/html',
            content_length: '27'
          )
        end

        specify do
          expect(subject.body).to eq("<h2>Hello World</h2>\n")
        end
      end
    end

  end
end
