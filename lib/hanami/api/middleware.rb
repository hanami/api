require "hanami/middleware/app"

module Hanami
  class API
    # Hanami::API middleware stack
    #
    # @since 0.1.0
    # @api private
    module Middleware
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

          Hanami::Middleware::App.new(app, mapping)
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
