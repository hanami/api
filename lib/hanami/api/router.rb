# frozen_string_literal: true

require "hanami/router"
require "hanami/api/block/context"

module Hanami
  class API
    class Router < ::Hanami::Router
      def initialize(stack:, **kwargs, &blk)
        @stack = stack
        super(block_context: Block::Context, **kwargs, &blk)
      end

      def freeze
        return self if frozen?

        remove_instance_variable(:@stack)
        super
      end

      def use(middleware, *args, &blk)
        @stack.use(middleware, args, &blk)
      end

      def scope(*args, **kwargs, &blk)
        @stack.with(args.first) do
          super
        end
      end
    end
  end
end
