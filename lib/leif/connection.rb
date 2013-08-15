require 'faraday'
require 'faraday_middleware'

module Leif
  class Connection
    attr_reader :connection

    def initialize(connection)
      @connection = connection
    end

    def self.to_url(url, options = {})
      connection = default_connection(url)
      if options.has_key?(:username) and options.has_key?(:password)
        connection.basic_auth options.fetch(:username),
                              options.fetch(:password)
      elsif options.has_key?(:token)
        connection.token_auth options.fetch(:token)
      end
      new(connection)
    end

    def self.default_connection(url)
      Faraday.new(url: url) do |config|
        config.request  :url_encoded
        config.response :json, :content_type => /\bjson$/
        config.adapter  Faraday.default_adapter
      end
    end

    def request(path, data = {}, method = :unset)
      method = data.empty? ? :get : :post if method == :unset
      Exchange.new(connection.send(method, path, data))
    end

    class Exchange
      attr_reader :exchange

      def initialize(exchange)
        @exchange = exchange
      end

      def method
        exchange.env[:method].upcase
      end

      def uri
        exchange.env[:url].request_uri
      end

      def request_headers
        exchange.env[:request_headers]
      end

      def request_body
        exchange.env[:body]
      end

      def response_headers
        exchange.headers
      end

      def response_body
        exchange.body
      end
    end
  end
end
