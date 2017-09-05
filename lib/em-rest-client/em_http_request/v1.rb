RestClient::EmHttpRequest.class_eval do

  private

  def build_connect_timeout
    open_timeout
  end

  def build_inactivity_timeout
    timeout
  end

  def build_proxy_uri
    return unless RestClient.proxy
    URI.parse(RestClient.proxy)
  end

end
