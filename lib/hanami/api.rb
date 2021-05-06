# frozen_string_literal: true

module Hanami
  # Hanami::API
  #
  # @since 0.1.0
  class API
    require "hanami/api/version"
    require "hanami/api/error"
    require "hanami/api/router"
    require "hanami/api/middleware"
    require "hanami/api/dsl"

    # @since 0.1.0
    # @api private
    def self.inherited(app)
      super

      app.extend(DSL::ClassMethods)
      app.include(DSL::InstanceMethods)
    end

    # Defines helper methods available within the block context.
    # Helper methods have access to default utilities available in block
    # context (e.g. `#halt`).
    #
    # @param mod [Module] optional module to include in block context
    # @param blk [Proc] inline helper definitions
    #
    # @since x.x.x
    #
    # @example Iniline helpers definition
    #   require "hanami/api"
    #
    #   class MyAPI < Hanami::API
    #     helpers do
    #       def redirect_to_root
    #         # redirect method is provider by Hanami::API block context
    #         redirect "/"
    #       end
    #     end
    #
    #     root { "Hello, World" }
    #
    #     get "/legacy" do
    #       redirect_to_root
    #     end
    #   end
    #
    # @example Module helpers definition
    #   require "hanami/api"
    #
    #   class MyAPI < Hanami::API
    #     module Authentication
    #       private
    #
    #       def unauthorized
    #         halt(401)
    #       end
    #     end
    #
    #     helpers(Authentication)
    #
    #     root { "Hello, World" }
    #
    #     get "/secrets" do
    #       unauthorized
    #     end
    #   end
    def self.helpers(mod = nil, &blk)
      const_get(:BlockContext).include(mod || Module.new(&blk))
    end

    # Defines a named root route (a GET route for "/")
    #
    # @param to [#call] the Rack endpoint
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @since 0.1.0
    #
    # @see .get
    #
    # @example Proc endpoint
    #   require "hanami/router"
    #
    #   router = Hanami::Router.new do
    #     root to: ->(env) { [200, {}, ["Hello from Hanami!"]] }
    #   end
    #
    # @example Block endpoint
    #   require "hanami/router"
    #
    #   router = Hanami::Router.new do
    #     root do
    #       "Hello from Hanami!"
    #     end
    #   end
    def self.root(*args, **kwargs, &blk)
      @router.root(*args, **kwargs, &blk)
    end

    # Defines a route that accepts GET requests for the given path.
    # It also defines a route to accept HEAD requests.
    #
    # @param path [String] the relative URL to be matched
    # @param to [#call] the Rack endpoint
    # @param as [Symbol] a unique name for the route
    # @param constraints [Hash] a set of constraints for path variables
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @since 0.1.0
    #
    # @example Proc endpoint
    #   require "hanami/api"
    #
    #   class MyAPI < Hanami::API
    #     get "/", to: ->(*) { [200, {}, ["OK"]] }
    #   end
    #
    # @example Block endpoint
    #   require "hanami/api"
    #
    #   class MyAPI < Hanami::API
    #     get "/" do
    #       "OK"
    #     end
    #   end
    #
    # @example Constraints
    #   require "hanami/api"
    #
    #   class MyAPI < Hanami::API
    #     get "/users/:id", to: ->(*) { [200, {}, ["OK"]] }, id: /\d+/
    #   end
    def self.get(*args, **kwargs, &blk)
      @router.get(*args, **kwargs, &blk)
    end

    # Defines a route that accepts POST requests for the given path.
    #
    # @param path [String] the relative URL to be matched
    # @param to [#call] the Rack endpoint
    # @param as [Symbol] a unique name for the route
    # @param constraints [Hash] a set of constraints for path variables
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @since 0.1.0
    #
    # @see .get
    def self.post(*args, **kwargs, &blk)
      @router.post(*args, **kwargs, &blk)
    end

    # Defines a route that accepts PATCH requests for the given path.
    #
    # @param path [String] the relative URL to be matched
    # @param to [#call] the Rack endpoint
    # @param as [Symbol] a unique name for the route
    # @param constraints [Hash] a set of constraints for path variables
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @since 0.1.0
    #
    # @see .get
    def self.patch(*args, **kwargs, &blk)
      @router.patch(*args, **kwargs, &blk)
    end

    # Defines a route that accepts PUT requests for the given path.
    #
    # @param path [String] the relative URL to be matched
    # @param to [#call] the Rack endpoint
    # @param as [Symbol] a unique name for the route
    # @param constraints [Hash] a set of constraints for path variables
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @since 0.1.0
    #
    # @see .get
    def self.put(*args, **kwargs, &blk)
      @router.put(*args, **kwargs, &blk)
    end

    # Defines a route that accepts DELETE requests for the given path.
    #
    # @param path [String] the relative URL to be matched
    # @param to [#call] the Rack endpoint
    # @param as [Symbol] a unique name for the route
    # @param constraints [Hash] a set of constraints for path variables
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @since 0.1.0
    #
    # @see .get
    def self.delete(*args, **kwargs, &blk)
      @router.delete(*args, **kwargs, &blk)
    end

    # Defines a route that accepts TRACE requests for the given path.
    #
    # @param path [String] the relative URL to be matched
    # @param to [#call] the Rack endpoint
    # @param as [Symbol] a unique name for the route
    # @param constraints [Hash] a set of constraints for path variables
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @since 0.1.0
    #
    # @see .get
    def self.trace(*args, **kwargs, &blk)
      @router.trace(*args, **kwargs, &blk)
    end

    # Defines a route that accepts OPTIONS requests for the given path.
    #
    # @param path [String] the relative URL to be matched
    # @param to [#call] the Rack endpoint
    # @param as [Symbol] a unique name for the route
    # @param constraints [Hash] a set of constraints for path variables
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @since 0.1.0
    #
    # @see .get
    def self.options(*args, **kwargs, &blk)
      @router.options(*args, **kwargs, &blk)
    end

    # Defines a route that accepts LINK requests for the given path.
    #
    # @param path [String] the relative URL to be matched
    # @param to [#call] the Rack endpoint
    # @param as [Symbol] a unique name for the route
    # @param constraints [Hash] a set of constraints for path variables
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @since 0.1.0
    #
    # @see .get
    def self.link(*args, **kwargs, &blk)
      @router.link(*args, **kwargs, &blk)
    end

    # Defines a route that accepts UNLINK requests for the given path.
    #
    # @param path [String] the relative URL to be matched
    # @param to [#call] the Rack endpoint
    # @param as [Symbol] a unique name for the route
    # @param constraints [Hash] a set of constraints for path variables
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @since 0.1.0
    #
    # @see .get
    def self.unlink(*args, **kwargs, &blk)
      @router.unlink(*args, **kwargs, &blk)
    end

    # Defines a route that redirects the incoming request to another path.
    #
    # @param path [String] the relative URL to be matched
    # @param to [#call] the Rack endpoint
    # @param as [Symbol] a unique name for the route
    # @param code [Integer] a HTTP status code to use for the redirect
    #
    # @since 0.1.0
    #
    # @see .get
    def self.redirect(*args, **kwargs, &blk)
      @router.redirect(*args, **kwargs, &blk)
    end

    # Defines a routing scope. Routes defined in the context of a scope,
    # inherit the given path as path prefix and as a named routes prefix.
    #
    # @param path [String] the scope path to be used as a path prefix
    # @param blk [Proc] the routes definitions withing the scope
    #
    # @since 0.1.0
    #
    # @see #path
    #
    # @example
    #   require "hanami/api"
    #
    #   class MyAPI < Hanami::API
    #     scope "v1" do
    #       get "/users", to: ->(*) { ... }, as: :users
    #     end
    #   end
    #
    #   # It generates a route with a path `/v1/users`
    def self.scope(*args, **kwargs, &blk)
      @router.scope(*args, **kwargs, &blk)
    end

    # Mount a Rack application at the specified path.
    # All the requests starting with the specified path, will be forwarded to
    # the given application.
    #
    # All the other methods (eg `#get`) support callable objects, but they
    # restrict the range of the acceptable HTTP verb. Mounting an application
    # with #mount doesn't apply this kind of restriction at the router level,
    # but let the application to decide.
    #
    # @param app [#call] a class or an object that responds to #call
    # @param at [String] the relative path where to mount the app
    # @param constraints [Hash] a set of constraints for path variables
    #
    # @since 0.1.0
    #
    # @example
    #   require "hanami/api"
    #
    #   class MyAPI < Hanami::API
    #     mount MyRackApp.new, at: "/foo"
    #   end
    def self.mount(*args, **kwargs, &blk)
      @router.mount(*args, **kwargs, &blk)
    end

    # Use a Rack middleware
    #
    # @param middleware [Class,#call] a Rack middleware
    # @param args [Array<Object>] an optional array of arguments for Rack middleware
    # @param blk [Block] an optional block to pass to the Rack middleware
    #
    # @since 0.1.0
    #
    # @example
    #   require "hanami/api"
    #
    #   class MyAPI < Hanami::API
    #     use MyRackMiddleware
    #   end
    def self.use(middleware, *args, &blk)
      @router.use(middleware, *args, &blk)
    end

    # TODO: verify if needed here on in block context
    #
    # @since 0.1.0
    # @api private
    def path(name, variables = {})
      @url_helpers.path(name, variables)
    end

    # TODO: verify if needed here on in block context
    #
    # @since 0.1.0
    # @api private
    def url(name, variables = {})
      @url_helpers.url(name, variables)
    end
  end
end
