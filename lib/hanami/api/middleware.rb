# frozen_string_literal: true

module Hanami
  class API
    # Hanami::API middleware stack
    #
    # @since 0.1.0
    # @api private
    module Middleware
      require "hanami/api/middleware/app"
      require "hanami/api/middleware/trie"

      # Middleware stack
      #
      # @since 0.1.0
      # @api private
      class Stack
        # @since 0.1.0
        # @api private
        def initialize(prefix)
          @prefix = prefix
          @stack = {}
        end

        # @since 0.1.0
        # @api private
        def use(path, middleware, *args, &blk)
          # FIXME: test with prefix when Hanami::API.settings and prefix will be supported
          @stack[path] ||= []
          @stack[path].push([middleware, args, blk])
        end

        # @since 0.1.1
        # @api private
        def to_hash
          @stack.each_with_object({}) do |(path, _), result|
            result[path] = stack_for(path)
          end
        end

        # @since 0.1.1
        # @api private
        def finalize(app)
          mapping = to_hash
          return app if mapping.empty?

          App.new(app, @prefix, mapping)
        end

        private

        # @since 0.1.1
        # @api private
        def stack_for(current_path)
          @stack.each_with_object([]) do |(path, stack), result|
            next unless current_path.start_with?(path)

            result.push(stack)
          end.flatten(1)
        end
      end
    end
  end
end
