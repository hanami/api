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

    def self.inherited(app)
      super

      app.class_eval do
        @routes = []
        @stack = Middleware::Stack.new
      end
    end

    class << self
      attr_reader :routes, :stack
    end

    def self.root(*args, **kwargs, &blk)
      @routes << [:root, args, kwargs, blk]
    end

    def self.get(*args, **kwargs, &blk)
      @routes << [:get, args, kwargs, blk]
    end

    def self.post(*args, **kwargs, &blk)
      @routes << [:post, args, kwargs, blk]
    end

    def self.patch(*args, **kwargs, &blk)
      @routes << [:patch, args, kwargs, blk]
    end

    def self.put(*args, **kwargs, &blk)
      @routes << [:put, args, kwargs, blk]
    end

    def self.delete(*args, **kwargs, &blk)
      @routes << [:delete, args, kwargs, blk]
    end

    def self.trace(*args, **kwargs, &blk)
      @routes << [:trace, args, kwargs, blk]
    end

    def self.options(*args, **kwargs, &blk)
      @routes << [:options, args, kwargs, blk]
    end

    def self.link(*args, **kwargs, &blk)
      @routes << [:link, args, kwargs, blk]
    end

    def self.unlink(*args, **kwargs, &blk)
      @routes << [:unlink, args, kwargs, blk]
    end

    def self.redirect(*args, **kwargs, &blk)
      @routes << [:redirect, args, kwargs, blk]
    end

    def self.scope(*args, **kwargs, &blk)
      @routes << [:scope, args, kwargs, blk]
    end

    def self.mount(*args, **kwargs, &blk)
      @routes << [:mount, args, kwargs, blk]
    end

    def self.use(middleware, *args, &blk)
      @stack.use(middleware, args, &blk)
    end

    def initialize(routes: self.class.routes, stack: self.class.stack)
      @stack = stack
      @router = Router.new(stack: @stack) do
        routes.each do |method_name, args, kwargs, blk|
          send(method_name, *args, **kwargs, &blk)
        end
      end

      freeze
    end

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

    def call(env)
      @app.call(env)
    end

    # TODO: verify if needed here on in block context
    def path(name, variables = {})
      @url_helpers.path(name, variables)
    end

    # TODO: verify if needed here on in block context
    def url(name, variables = {})
      @url_helpers.url(name, variables)
    end
  end
end
