module Puppetforge
  class Client

    # Methods for the Users API
    #
    # @see https://forgeapi.puppetlabs.com/
    module Forgemodule

      # Search for modules
      #
      # Returns a list of modules meeting the specified criteria. Results are paginated and all of 
      # the parameters are optional.
      #
      # @param options [Hash] Optional options.
      # @option options [String] :query General search query
      # @option options [String] :owner Search for modules with a given owner
      # @option options [String] :tag Limits the results to modules that have the given tag
      # @option options [Boolean] :show_deleted Includes modules with no releases in the results
      # @option options [String] :sort_by Change the order in which results are returned.
      #  valid values: rank, downloads, latest_release
      # @option options [Integer] :limit Limits the number of results per page (default is 20)
      # @option options [Integer] :offset Omits results from the beginning of the set, used for pagination (default is 0)
      # @option options [Date-Time] :if_modified_since Only processes the request if there has been a change since this time
      #
      # @return [Array<Object>]
      #
      def modules(options={})
        paginate "modules", options
      end

      # Find latest module for a user and module name
      #
      # Requires both user and module to be defined. No optional parameters are supported for this endpoint, 
      # so use the /modules endpoint if you want to omit something and/or specify additional criteria.
      #
      # @param user [String] The name of the user who maintains the module.
      # @param module_name [String] The name of the module to be queried.
      #
      # @return [Object]
      # @example
      #   Puppetforge.module("puppetlabs", "ntp")
      #
      def module(user, module_name)
      	get "modules/#{user}-#{module_name}"
      end

    end
  end
end
