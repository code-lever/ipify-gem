require 'ipify/version'
require 'net/http'
require 'retriable'

module Ipify

  ConnectionError = Class.new(StandardError)
  ServiceError = Class.new(StandardError)

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
  # @raise [Ipify::ConnectionError] if unable to reach the ipify service
  # @raise [Ipify::ServiceError] if the ipify service returns status other than 200(OK)

  def self.ip!
    http = build_http
    response = Retriable.retriable tries: 3 do
      http.get('/')
    end
    raise ServiceError, "ipify.org returned status #{response.code}" if '200' != response.code
    response.body
  rescue Net::OpenTimeout
    raise ConnectionError, "ipify.org timed out"
  end

  private

  # @return [Net::HTTP] http client
  def self.build_http
    uri = URI('https://api.ipify.org')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 1
    http.read_timeout = 1
    http
  end

end
