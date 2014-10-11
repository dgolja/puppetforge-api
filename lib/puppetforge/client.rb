require 'faraday'
require 'uri'
require 'json'
require 'set'

require 'puppetforge/configurable'
require 'puppetforge/errors'
require 'puppetforge/client/module'
require 'puppetforge/client/user'
require 'puppetforge/client/release'
require 'puppetforge/response'

module Puppetforge

  #
  # Client for the Puppet Forge API
  #

  class Client
    include Puppetforge::Configurable
    include Puppetforge::Client::Forgemodule
    include Puppetforge::Client::User
    include Puppetforge::Client::Release

    # Header keys that can be passed in options hash to {#get},{#head}
    CONVENIENCE_HEADERS = Set.new([:accept, :content_type, :if_modified_since])

    # HTTP requests who that does not need the body content. Current API version no body is needed
    # however I guess in the future that can change
    NO_BODY = Set.new([:get, :head]) 

    def initialize(options = {})
      # Use options passed in, but fall back to module defaults
      Puppetforge::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", options[key] || Puppetforge.instance_variable_get(:"@#{key}"))
      end
    end

    # Compares client options to a Hash of requested options
    #
    # @param opts [Hash] Options to compare with current client options
    # @return [Boolean]
    def same_options?(opts)
      opts.hash == options.hash
    end

    # Make a HTTP GET request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Query and header params for request
    # @return [Faraday::Response]
    def get(url, options = {})
      request :get, url, parse_query_and_convenience_headers(options)
    end

    # Make one or more HTTP GET requests, optionally fetching
    # the next page of results from URL in Link response header based
    # on value in {#auto_paginate}.
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Query and header params for request
    # @param block [Block] Block to perform the data concatination of the
    #   multiple requests. The block is called with two parameters, the first
    #   contains the contents of the requests so far and the second parameter
    #   contains the latest response.
    # @return [Sawyer::Resource]
    def paginate(url, options = {}, &block)
      opts = parse_query_and_convenience_headers(options.dup)

      data = request(:get, url, opts)
      puts "data #{data}"
      if @auto_paginate
        unless @last_response.data['pagination']['next'] == 'null'
          @last_response = call(:get, URI::Parser.new.escape("#{@last_response.next}"), opts)
          if block_given?
            yield(@last_response.data, @last_response)
          else
            data['results'] << @last_response.data['results'] if @last_response.data['results'].is_a?(Array)
          end
        end
      end
      data
    end

    # Response for last HTTP request
    #
    # @return [Sawyer::Response]
    def last_response
      @last_response if defined? @last_response
    end

    private

    def request(method, path, data, options = {})

      if data.is_a?(Hash)
        options[:query]   = data.delete(:query) || {}
        options[:headers] = data.delete(:headers) || {}
        if accept = data.delete(:accept)
          options[:headers][:accept] = accept
        end
      end
      
      @last_response = response = call(method,  URI::Parser.new.escape("#{api_version}/#{path}"), data, options)
      response.data      
    end

    def call(method, url, data = nil, options = nil)
      if NO_BODY.include?(method)
        options ||= data
        data      = nil
      end

      options ||= {}

      res = agent.send method, url do |req|
        if data
          req.body = data.is_a?(String) ? data : encode_body(data)
        end
        if params = options[:query]
          req.params.update params
        end
        if headers = options[:headers]
          req.headers.update headers
        end
      end
      Response.new res
    end

    def faraday_options
      opts = @connection_options
      opts[:builder] = @middleware if @middleware
      opts
    end

    def agent
      @agent ||= Faraday.new(api_endpoint, faraday_options)
    end

    def parse_query_and_convenience_headers(options)
      headers = options.fetch(:headers, {})
      CONVENIENCE_HEADERS.each do |h|
        if header = options.delete(h)
          headers[h] = header
        end
      end
      query = options.delete(:query)
      opts = {:query => options}
      opts[:query].merge!(query) if query && query.is_a?(Hash)
      opts[:headers] = headers unless headers.empty?
      opts
    end

    # Not used at the moment because the current API has no body request
    # however you don't know what the future brings :)
    # here we assume that the format of the body will be json
    def encode_body(data)
      data.to_json
    end

  end
end