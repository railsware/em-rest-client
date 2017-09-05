require 'rest_client'

module RestClient
  class << self
    attr_reader :major_version
    attr_accessor :adapter
  end

  self.instance_variable_set :@major_version, VERSION.to_i
  self.adapter = :net_http
end
