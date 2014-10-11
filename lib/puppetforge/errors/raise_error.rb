require 'faraday'
require 'puppetforge/errors'

module Puppetforge
  # Faraday response middleware
  module Errors

    # This class raises an Puppetforge-flavored exception based
    # HTTP status codes returned by the API
    class RaiseError < Faraday::Response::Middleware

      private

      def on_complete(response)
        if error = Puppetforge::Error.from_response(response)
          puts "looks like on_complete there is something with error: class => #{error.class}"
          raise error
        end
      end
    end
  end
end