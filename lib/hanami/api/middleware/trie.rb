# frozen_string_literal: true

require "hanami/api/middleware/node"

module Hanami
  class API
    module Middleware
      # Trie to register scopes with custom Rack middleware
      #
      # @api private
      # @since 0.1.1
      class Trie
        # @api private
        # @since 0.1.1
        def initialize(app)
          @app = app
          @root = Node.new
        end

        # @api private
        # @since 0.1.1
        def freeze
          @root.freeze
          super
        end

        # @api private
        # @since 0.1.1
        def add(path, app)
          node = @root
          for_each_segment(path) do |segment|
            node = node.put(segment)
          end

          node.app!(app)
        end

        # @api private
        # @since 0.1.1
        def find(path)
          node = @root

          for_each_segment(path) do |segment|
            break unless node

            node = node.get(segment)
          end

          return node.app if node&.app?

          @root.app || @app
        end

        # @api private
        # @since 0.1.1
        def empty?
          @root.leaf?
        end

        private

        # @api private
        # @since 0.1.1
        def for_each_segment(path, &blk)
          _, *segments = path.split(/\//)
          segments.each(&blk)
        end
      end
    end
  end
end
