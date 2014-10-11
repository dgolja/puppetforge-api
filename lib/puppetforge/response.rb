require 'json'
require 'puppetforge/errors'

module Puppetforge
  class Response
    attr_reader :headers, :body, :status, :data

    def initialize(response)
      @response = response
      @status  = response.status.to_i
      @headers = response.headers

      if (body = response.body) && !body.empty?
      	begin
    	  body = JSON.parse(body)
          if body['pagination']
            @pagination = body['pagination']
            instance_variable_get(:"@pagination")
            @data = body['results']
          else
          	@data = body
          end
    	rescue => e
    	  raise Puppetforge::BodyJsonError.new(e)
    	end
  	  end
  	end

    def method_missing(method_name, *args, &block)
	  return @data['pagination'][meth.to_s] if @data['pagination'] and @data['pagination'].keys.include?(meth.to_s)
	  super
    end

    def respond_to?(method_name)
      return true if @data['pagination'] and @data['pagination'].keys.include?(meth.to_s)
      super
    end
  end
end
