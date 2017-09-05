require 'em-http'
require 'fiber'

module RestClient
  class EmHttpRequest < Request

    def initialize(args)
      raise ArgumentError, ':block_response option is not supported' if args[:block_response]
      super(args)
    end

    def execute(&block)
      uri = parse_url_with_auth(url)
      connection = build_connection(uri)
      client = transmit(connection, &block)
      raise client.error if client.error
      net_http_response = build_net_http_response(client)
      process_result(net_http_response, &block)
    ensure
      payload.close if payload
    end

    private

    def transmit(connection, &block)
      client = nil
      if EM.reactor_running?
        client = sync_transmit(connection, &block)
      else
        EM.run do
          Fiber.new do
            client = sync_transmit(connection, &block)
            EM.stop
          end.resume
        end
      end
      client
    end

    def sync_transmit(connection, &block)
      client = build_client(connection)
      if client.error
        client
      else
        fiber = Fiber.current
        client.callback { fiber.resume(client) }
        client.errback { fiber.resume(client) }
        Fiber.yield
      end
    end

    def build_connection(uri)
      uri = uri.dup
      uri.user = nil
      uri.password = nil
      EM::HttpRequest.new(uri, build_connection_options)
    end

    def build_client(connection)
      connection.setup_request(method, build_request_options)
    end

    def build_connection_options
      options = {}

      if connect_timeout = build_connect_timeout
        options[:connect_timeout] = connect_timeout
      end

      if inactivity_timeout = build_inactivity_timeout
        options[:inactivity_timeout] = inactivity_timeout
      end

      if proxy_uri = build_proxy_uri
        options[:proxy] = {
          host: proxy_uri.host,
          port: proxy_uri.port,
          authorization: [proxy_uri.user, proxy_uri.password]
        }
      end

      options
    end

    def build_request_options
      options = {}
      options[:decoding] = false
      options[:head] = processed_headers
      if user
        options[:head]['authorization'] = [user, password]
      end
      options[:body] = payload.to_s
      options
    end

    def build_net_http_response(client)
      klass = Net::HTTPResponse.send(
        :response_class,
        client.response_header.status.to_s
      )
      response = klass.new(
        client.response_header.http_version,
        client.response_header.status.to_s,
        client.response_header.http_reason
      )
      client.response_header.raw.each do |k, v|
        response.add_field(k, v)
      end
      response.body = client.response
      response.instance_variable_set :@read, true
      response
    end
  end
end
