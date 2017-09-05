module RestClient
  class Request
    class << self
      def execute(args, &block)
        adapter_name = args.fetch(:adapter, RestClient.adapter)
        klass = get_adapter_klass(adapter_name)
        klass.new(args).execute(&block)
      end

      def get_adapter_klass(name)
        case name
        when :net_http
          Request
        when :em_http
          EmHttpRequest
        else
          raise NotImplementedError, "Unsupported adapter: #{adapter.inspect}"
        end
      end
    end
  end
end
