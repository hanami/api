# frozen_string_literal: true

module Hanami
  class API
    module Middleware
      # Trie node to register scopes with custom Rack middleware
      #
      # @api private
      # @since 0.1.1
      class Node
        # @api private
        # @since 0.1.1
        attr_reader :app

        # @api private
        # @since 0.1.1
        def initialize
          @app = nil
          @children = {}
        end

        # @api private
        # @since 0.1.1
        def freeze
          @children.each(&:freeze)
          super
        end

        # @api private
        # @since 0.1.1
        def put(segment)
          @children[segment] ||= self.class.new
        end

        # @api private
        # @since 0.1.1
        def get(segment)
          @children.fetch(segment) { self if leaf? }
        end

        # @api private
        # @since 0.1.1
        def app!(app)
          @app = app
        end

        # @api private
        # @since 0.1.1
        def app?
          @app
        end

        # @api private
        # @since 0.1.1
        def leaf?
          @children.empty?
        end
      end
    end
  end
end
