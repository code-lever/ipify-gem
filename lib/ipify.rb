require 'ipify/version'
require 'net/http'
require 'retriable'

module Ipify

  def self.ip
    http = build_http
    Retriable.retriable tries: 3 do
      http.get('/').body
    end
  end

  private

  def self.build_http
    uri = URI('https://api.ipify.org')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 5
    http
  end

end
