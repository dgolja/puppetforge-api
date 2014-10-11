module Puppetforge
  class Error < StandardError

    # Returns the appropriate Puppetforge::Error sublcass based
    # on status and response message
    #
    # @param [Hash] response HTTP response
    # @return [Puppetforge::Error]
    def self.from_response(response)
      status = response.status.to_i
      if klass = case status
                 when 400      then Puppetforge::BadRequest
                 when 404      then Puppetforge::NotFound
                 when 400..499 then Puppetforge::ClientError
                 when 500      then Puppetforge::InternalServerError
                 when 500..599 then Puppetforge::ServerError
                 end
        klass.new(response)
      end
    end

    def initialize(response = nil)
      @response = response
      super(build_error_message)
    end
  
    private

    def response_message
  	  case data
  	  when Hash
        data["message"]
      else
        nil
  	  end
    end

    def response_errors
  	  case data
  	  when Hash
        data["errors"]
      else
        nil
      end
    end

    def data
  	  @data ||= 
      if (body = @response.body) && !body.empty?
  	    body = JSON.parse(body) rescue nil
      else
        nil
  	  end
    end

    def build_error_message
  	  return nil if @response.nil?
      message = "Status code: #{@response.status} - "
      message << response_message ? response_message : "Unknown error"
 	  message << " - #{response_errors}" unless response_errors.nil?
 	  puts "message from build_error_message => #{message}"
 	  message
    end

  end
  # Probably this section could be improved based on Puppet Forge status code

  # Raised when 400..499 HTTP code
  class ClientError < Error; end

  # Raised when 400 HTTP code
  class BadRequest < ClientError; end

  # Raised when Puppet Forge returns a 404 HTTP status code
  class NotFound < ClientError; end
   
  # Raised when 500 HTTP code
  class InternalServerError < Error; end

  # Defaul 500 HTTP code
  class ServerError < InternalServerError; end

  # If body content is not a proper JSON 
  class BodyJsonError < Error; end

end
