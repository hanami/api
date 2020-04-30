# frozen_string_literal: true

require "hanami/router/prefix"
require "hanami/api/middleware/node"

module Hanami
  class API
    module Middleware
      # Endpoint resolver trie to register slices
      #
      # @api private
      # @since 2.0.0
      class Trie
        attr_reader :prefix

        # @api private
        # @since 2.0.0
        def initialize(prefix)
          @prefix = Hanami::Router::Prefix.new(prefix)
          @root = Node.new
        end

        # @api private
        # @since 2.0.0
        def add(path, middleware)
          node = @root
          for_each_segment(path) do |segment|
            node = node.put(segment)
          end

          node.middleware!(middleware)
        end

        def each(node = @root, prefix = self.prefix, stack = [], result = {}, &blk)
          if @root.middleware_stack.any?
            result[self.prefix.to_s] ||= stack
            result[self.prefix.to_s] += @root.middleware_stack
          end

          node.each_child do |segment, child|
            path = prefix.join(segment)
            if child.middleware_stack.any?
              result[path.to_s] ||= stack
              result[path.to_s] += child.middleware_stack
            end

            return each(child, path, result[path.to_s], result, &blk) unless child.leaf?
          end

          result.each(&blk)
        end

        # @api private
        # @since 2.0.0
        def find(path)
          node = @root

          for_each_segment(path) do |segment|
            break unless node

            node = node.get(segment)
          end

          return node.slice if node&.leaf?

          nil
        end

        def empty?
          @root.leaf?
        end

        private

        # @api private
        # @since 2.0.0
        def for_each_segment(path, &blk)
          _, *segments = path.split(/\//)
          segments.each(&blk)
        end
      end
    end
  end
end
