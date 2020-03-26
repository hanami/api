# frozen_string_literal: true

require "hanami/router"
require "hanami/api/block/context"

module Hanami
  class API
    # @since 0.1.0
    class Router < ::Hanami::Router
      # @since 0.1.0
      # @api private
      def initialize(stack:, **kwargs, &blk)
        @stack = stack
        super(block_context: Block::Context, **kwargs, &blk)
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
        @stack.use(middleware, args, &blk)
      end

      # @since 0.1.0
      # @api private
      def scope(*args, &blk)
        @stack.with(args.first) do
          super
        end
      end
    end
  end
end
