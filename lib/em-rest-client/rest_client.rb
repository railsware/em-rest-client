require 'rest_client'

module RestClient
  class << self
    attr_accessor :adapter
  end

  class Request
    class << self
      def execute(args, &block)
        adapter = args.fetch(:adapter, RestClient.adapter)
        klass =
          case adapter
          when :net_http
            Request
          when :em_http
            EmHttpRequest
          else
            raise NotImplementedError, "Unsupported adapter: #{adapter.inspect}"
          end
        klass.new(args).execute(&block)
      end
    end
  end
end

RestClient.adapter = :net_http
