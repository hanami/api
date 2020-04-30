# frozen_string_literal: true

module Hanami
  class API
    module Middleware
      # Endpoint resolver node to register middlewares in a tree
      #
      # @api private
      # @since 2.0.0
      class Node
        # @api private
        # @since 2.0.0
        attr_reader :middleware_stack

        # @api private
        # @since 2.0.0
        def initialize
          @middleware_stack = []
          @children = {}
        end

        # @api private
        # @since 2.0.0
        def put(segment)
          @children[segment] ||= self.class.new
        end

        # @api private
        # @since 2.0.0
        def get(segment)
          @children.fetch(segment) { self if leaf? }
        end

        def each_child(&blk)
          @children.each(&blk)
        end

        # @api private
        # @since 2.0.0
        def middleware!(middleware)
          @middleware_stack.push(middleware)
        end

        # @api private
        # @since 2.0.0
        def leaf?
          @children.empty?
        end
      end
    end
  end
end
