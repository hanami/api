# frozen_string_literal: true

require "hanami/router"
require "hanami/api/block/context"

module Hanami
  class API
    # @since x.x.x
    class Router < ::Hanami::Router
      # @since x.x.x
      # @api private
      def initialize(stack:, **kwargs, &blk)
        @stack = stack
        super(block_context: Block::Context, **kwargs, &blk)
      end

      # @since x.x.x
      # @api private
      def freeze
        return self if frozen?

        remove_instance_variable(:@stack)
        super
      end

      # @since x.x.x
      # @api private
      def use(middleware, *args, &blk)
        @stack.use(middleware, args, &blk)
      end

      # @since x.x.x
      # @api private
      def scope(*args, **kwargs, &blk)
        @stack.with(args.first) do
          super
        end
      end
    end
  end
end
