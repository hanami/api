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

    # @since x.x.x
    # @api private
    def self.inherited(app)
      super

      app.class_eval do
        @routes = []
        @stack = Middleware::Stack.new
      end
    end

    class << self
      # @since x.x.x
      # @api private
      attr_reader :routes

      # @since x.x.x
      # @api private
      attr_reader :stack
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
      @routes << [:root, args, kwargs, blk]
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
      @routes << [:get, args, kwargs, blk]
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
      @routes << [:post, args, kwargs, blk]
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
      @routes << [:patch, args, kwargs, blk]
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
      @routes << [:put, args, kwargs, blk]
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
      @routes << [:delete, args, kwargs, blk]
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
      @routes << [:trace, args, kwargs, blk]
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
      @routes << [:options, args, kwargs, blk]
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
      @routes << [:link, args, kwargs, blk]
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
      @routes << [:unlink, args, kwargs, blk]
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
      @routes << [:redirect, args, kwargs, blk]
    end

    # Defines a routing scope. Routes defined in the context of a scope,
    # inherit the given path as path prefix and as a named routes prefix.
    #
    # @param path [String] the scope path to be used as a path prefix
    # @param blk [Proc] the routes definitions withing the scope
    #
    # @since x.x.x
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
      @routes << [:scope, args, kwargs, blk]
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
      @routes << [:mount, args, kwargs, blk]
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
      @stack.use(middleware, args, &blk)
    end

    # @since x.x.x
    def initialize(routes: self.class.routes, stack: self.class.stack)
      @stack = stack
      @router = Router.new(stack: @stack) do
        routes.each do |method_name, args, kwargs, blk|
          send(method_name, *args, **kwargs, &blk)
        end
      end

      freeze
    end

    # @since x.x.x
    def freeze
      @app = @stack.finalize(@router)
      @url_helpers = @router.url_helpers
      @router.remove_instance_variable(:@url_helpers)
      remove_instance_variable(:@stack)
      remove_instance_variable(:@router)
      @url_helpers.freeze
      @app.freeze
      super
    end

    # @since x.x.x
    def call(env)
      @app.call(env)
    end

    # TODO: verify if needed here on in block context
    #
    # @since x.x.x
    # @api private
    def path(name, variables = {})
      @url_helpers.path(name, variables)
    end

    # TODO: verify if needed here on in block context
    #
    # @since x.x.x
    # @api private
    def url(name, variables = {})
      @url_helpers.url(name, variables)
    end
  end
end
