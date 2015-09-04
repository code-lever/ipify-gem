require 'ipify/version'
require 'net/http'
require 'retriable'

module Ipify

  # Requests this machine's IP address from the ipify.org service.  Will retry up to 3 times
  # until ultimately returning +nil+.
  #
  # @return [String] external ip address, or +nil+ if unsuccessful
  def self.ip
    ip! rescue nil
  end

  # Requests this machine's IP address from the ipify.org service.  Will retry up to 3 times
  # until ultimately raising the last exception encountered.
  #
  # @return [String] external ip address
  def self.ip!
    http = build_http
    Retriable.retriable tries: 3 do
      http.get('/').body
    end
  end

  private

  # @return [Net::HTTP] http client
  def self.build_http
    uri = URI('https://api.ipify.org')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 5
    http
  end

end
