shared_context :em_http_request_execute do
  subject { request.execute }

  let(:request) { described_class.new(args) }
  let(:args) { {} }
  let(:accept_header) do
    case RestClient.major_version
    when 1 then '*/*; q=0.5, application/xml'
    when 2 then '*/*'
    end
  end

end
