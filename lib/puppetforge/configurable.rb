module Puppetforge

  # Configuration options for {Client}, defaulting to values
  # in {Default}
  module Configurable
    # @!attribute [w] api_endpoint
    #   @return [String] Base URL for API requests. default: https://forgeapi.puppetlabs.com/
    # @!attribute  api_version
    #   @return [String] API Version. default: v3
    # @!attribute auto_paginate
    #   @return [Boolean] Auto fetch next page of results
    # @!attribute default_media_type
    #   @return [String] Configure preferred media type (for API versioning, for example)
    # @!attribute limit
    #   @return [String] Limits the number of results per page (default is 20)
    # @!attribute middleware
    #   @see https://github.com/lostisland/faraday
    #   @return [Faraday::RackBuilder] Configure middleware for Faraday    
    # @!attribute user_agent
    #   @return [String] Configure User-Agent header for requests.

    attr_accessor :api_version, :auto_paginate, :auto_paginate, 
                  :user_agent, :limit, :middleware, :connection_options,
                  :default_media_type
    attr_writer :api_endpoint

    class << self

      # List of configurable keys for {Puppetforge::Client}
      # @return [Array] of option keys
      def keys
        @keys ||= [
          :api_endpoint,
          :api_version,
          :auto_paginate,
          :connection_options,
          :default_media_type,
          :middleware,
          :limit,
          :user_agent
        ]
      end
    end

    # Set configuration options using a block
    def configure
      yield self
    end

    # Reset configuration options to default values
    def reset!
      Puppetforge::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", Puppetforge::Default.options[key])
      end
      self
    end
    alias setup reset!

    def api_endpoint
      File.join(@api_endpoint, "")
    end

    private

    def options
      Hash[Puppetforge::Configurable.keys.map{|key| [key, instance_variable_get(:"@#{key}")]}]
    end

  end
end