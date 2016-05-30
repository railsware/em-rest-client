shared_context :em_http_request_execute do
  let(:args) { {} }

  let(:request) { described_class.new(args) }

  subject { request.execute }
end
