RestClient::EmHttpRequest.class_eval do

  private

  alias_method :parse_url_with_auth, :parse_url_with_auth!

  def build_connect_timeout
    open_timeout
  end

  def build_inactivity_timeout
    read_timeout
  end

  def build_proxy_uri
    proxy_uri
  end

end
