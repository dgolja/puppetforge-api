require 'puppetforge/errors/raise_error'
require 'puppetforge/version'

module Puppetforge

  # Default configuration options for {Client}
  module Default

    # Default API endpoint
    API_ENDPOINT = "https://forgeapi.puppetlabs.com/".freeze

    # Default User Agent header string
    USER_AGENT   = "Puppet Forge Ruby Gem #{Puppetforge::VERSION}".freeze

    # Default media type
    MEDIA_TYPE   = "application/json"

    # Default API version
    API_VERSION  = "v3"

    # Default Faraday middleware stack
    MIDDLEWARE = Faraday::RackBuilder.new do |builder|
      builder.use Puppetforge::Errors::RaiseError
      builder.adapter Faraday.default_adapter
    end

    class << self

      # Configuration options
      # @return [Hash]
      def options
        Hash[Puppetforge::Configurable.keys.map{|key| [key, send(key)]}]
      end

      # Default API endpoint from ENV or {API_ENDPOINT}
      # @return [String]
      def api_endpoint
        ENV['PUPPETFORGE_API_ENDPOINT'] || API_ENDPOINT
      end

      # Default API version from {API_VERSION}
      # @return [String]
      def api_version
        API_VERSION
      end

      # Default pagination preference from ENV
      # @return [String]
      def auto_paginate
        ENV['PUPPETFORGE_AUTO_PAGINATE']
      end

      # Default options for Faraday::Connection
      # @return [Hash]
      def connection_options
        {
          :headers => {
            :accept => default_media_type,
            :user_agent => user_agent
          }
        }
      end

      # Default media type from ENV or {MEDIA_TYPE}
      # @return [String]
      def default_media_type
        ENV['PUPPETFORGE_DEFAULT_MEDIA_TYPE'] || MEDIA_TYPE
      end

      # Default middleware stack for Faraday::Connection
      # from {MIDDLEWARE}
      # @return [String]
      def middleware
        MIDDLEWARE
      end

      # Default pagination page size from ENV
      # @return [Fixnum] Page size
      def limit
        limit = ENV['PUPPETFORGE_LIMIT']

        limit.to_i if limit
        20 unless limit
      end

      # Default User-Agent header string from ENV or {USER_AGENT}
      # @return [String]
      def user_agent
        ENV['PUPPETFORGE_USER_AGENT'] || USER_AGENT
      end

    end
  end
end