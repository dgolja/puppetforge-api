module Puppetforge
  class Client

    # Methods for the Users API
    #
    # @see https://forgeapi.puppetlabs.com/
    module User

      # List all Puppet Forge users
      #
      # Provides information about Puppet Forge user accounts. By default, results are returned in alphabetical order by
      # username and paginated with 20 users per page. It's also possible to sort by other criteria
      #
      # @param options [Hash] Optional options.
      # @option options [String] :sort_by Changes the order of returned results
      #  valid values: (username|releases|downloads|latest_release)
      # @option options [Integer] :limit Limits the number of results per page (default is 20)
      # @option options [Integer] :offset Omits results from the beginning of the set, used for pagination (default is 0)
      # @option options [Date-Time] :if_modified_since Only processes the request if there has been a change since this time
      #
      # @return [Array<Object>] List of Puppet Forge users.
      def users(options = {})
        paginate "users", options
      end
      alias :all_users :users

      # Get a single user
      #
      # @param user [String] The name of the user who maintains the module.
      # @return [Object]
      # @example
      #   Puppetforge.user("golja")
      #
      def user(user, options = {})
        get "users/#{user}", options
      end

    end
  end
end
