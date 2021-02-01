# frozen_string_literal: true

require "hanami/router"
require "hanami/router/inspector"
require "hanami/api/block/context"

module Hanami
  class API
    # @since 0.1.0
    class Router < ::Hanami::Router
      # @since x.x.x
      # @api private
      attr_reader :inspector

      # @since 0.1.0
      # @api private
      def initialize(block_context: Block::Context, inspector: Inspector.new, **kwargs)
        super(block_context: block_context, inspector: inspector, **kwargs)
        @stack = Middleware::Stack.new(@path_prefix.to_s)
      end

      # @since 0.1.0
      # @api private
      def freeze
        return self if frozen?

        remove_instance_variable(:@stack)
        super
      end

      # @since 0.1.0
      # @api private
      def use(middleware, *args, &blk)
        @stack.use(@path_prefix.to_s, middleware, *args, &blk)
      end

      # @since 0.1.1
      # @api private
      def to_rack_app
        @stack.finalize(self)
      end

      # Returns formatted routes
      #
      # @return [String] formatted routes
      #
      # @since x.x.x
      # @api private
      def to_inspect
        @inspector.call
      end
    end
  end
end
