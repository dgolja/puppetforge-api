module Puppetforge
  class Client

    # Methods for the Users API
    #
    # @see https://forgeapi.puppetlabs.com/
    module Release

      # Get a list of releases
      #
      # Returns a paginated list of module releases. The results can be limited in a
      # number of ways, but all of the parameters are optional.
      #
      # @param options [Hash] Optional options.
      # @option options [String] :module Takes the form of '{user}-{module}', limits the results to releases of that module
      # @option options [String] :owner Limits results to modules with a given owner
      # @option options [String] :version Limits results to releases matching a version range
      # @option options [Boolean] :show_deleted Include deleted releases in the results
      # @option options [String] :sort_by Change the order in which results are returned.
      #  valid value: downloads, release_date, module
      # @option options [Integer] :limit Limits the number of results per page (default is 20)
      # @option options [Integer] :offset Omits results from the beginning of the set, used for pagination (default is 0)
      # @option options [Date-Time] :if_modified_since Only processes the request if there has been a change since this time
      #
      # @return [Array<Object>]
      #
      def releases(options={})
        paginate "releases", options
      end
      alias :all_releases :releases

      # Returns information about a given release
      #
      # @param user [String] The name of the user who maintains the module.
      # @param module_name [String] The name of the module to be queried.
      # @param version [String] the version of this release.
      #
      # @return [Object]
      # @example
      #   Puppetforge.user("golja")
      #
      def release(user, module_name, version)
        get "releases/#{user}-#{module_name}-#{version}"
      end
    end
  end
end
