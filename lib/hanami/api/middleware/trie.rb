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
        def initialize(app, prefix)
          @app = app
          @prefix = Hanami::Router::Prefix.new(prefix)
          @root = Node.new
        end

        def freeze
          @root.freeze
          super
        end

        # @api private
        # @since 2.0.0
        def add(path, app)
          node = @root
          for_each_segment(path) do |segment|
            node = node.put(segment)
          end

          node.app!(app)
        end

        # @api private
        # @since 2.0.0
        def find(path)
          node = @root

          for_each_segment(path) do |segment|
            break unless node

            node = node.get(segment)
          end

          return node.app if node&.app?

          @root.app || @app
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
