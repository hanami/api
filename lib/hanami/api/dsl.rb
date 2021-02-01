# frozen_string_literal: true

module Hanami
  class API
    # Expose Hanami::API features to third party frameworks that need to expose
    # a routing DSL.
    #
    # @since 0.2.0
    #
    # @example
    #   # framework.rb
    #    require "hanami/api"
    #
    #    module Framework
    #      class App
    #        def self.inherited(base)
    #          super
    #          base.extend(Hanami::API::DSL)
    #        end
    #      end
    #    end
    #
    #    # app.rb
    #    require "framework/app"
    #
    #    class MyApp < Framework::App
    #      routes do
    #        root { "Hello, World!" }
    #      end
    #    end
    #
    #    # config.ru
    #    require_relative "./app"
    #
    #    run MyApp.new
    module DSL
      # @since 0.2.0
      # @api private
      def self.extended(app)
        super

        app.extend(ClassMethods)
        app.extend(ClassMethods::Routes)
        app.include(InstanceMethods)
      end

      # @since 0.2.0
      # @api private
      module ClassMethods
        # @since 0.2.0
        # @api private
        attr_reader :router

        # @since 0.2.0
        # @api private
        def self.extended(app)
          super

          app.class_eval do
            @router = Router.new
          end
        end

        # @since 0.2.0
        # @api private
        module Routes
          # A block to define application routes
          #
          # This is ONLY available for third-party frameworks that use
          # Hanami::API DSL.
          #
          # If you use Hanami::API directly, this method isn't available.
          #
          # @param blk [Proc] the block to define the routes
          #
          # @see Hanami::API::Router
          #
          # @since 0.2.0
          # @api public
          def routes(&blk)
            router.instance_eval(&blk)
          end
        end
      end

      module InstanceMethods
        # Initialize the app
        #
        # @param router [Hanami::API::Router] the application router
        #
        # @since 0.2.0
        # @api public
        def initialize(router: self.class.router.dup)
          @router = router

          freeze
        end

        # @since 0.2.0
        # @api private
        def freeze
          @app = @router.to_rack_app
          @url_helpers = @router.url_helpers
          @router.remove_instance_variable(:@url_helpers)
          remove_instance_variable(:@router)
          @url_helpers.freeze
          @app.freeze
          super
        end

        # Compatibility with Rack protocol
        #
        # @param env [Hash] a Rack env for the current request
        #
        # @since 0.2.0
        # @api public
        def call(env)
          @app.call(env)
        end

        # Printable routes
        #
        # @return [String] printable routes
        #
        # @since x.x.x
        # @api public
        def to_inspect
          @app.to_inspect
        end
      end
    end
  end
end
