# frozen_string_literal: true

require "hanami/router"
require "hanami/api/block/context"

module Hanami
  class API
    # @since 0.1.0
    class Router < ::Hanami::Router
      # @since 0.1.0
      # @api private
      def initialize(block_context: Block::Context, **kwargs)
        super(block_context: block_context, **kwargs)
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
        return self if @stack.empty?

        @stack.finalize(self)
      end
    end
  end
end
