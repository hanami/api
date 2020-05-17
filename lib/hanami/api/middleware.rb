# frozen_string_literal: true

require "rack/builder"

module Hanami
  class API
    # Hanami::API middleware stack
    #
    # @since 0.1.0
    # @api private
    module Middleware
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
          # FIXME: test with prefix
          @stack[path] ||= []
          @stack[path].push([middleware, args, blk])
        end

        def to_hash
          @stack.each_with_object({}) do |(path, _), result|
            result[path] = stack_for(path)
          end
        end

        class App
          def initialize(app, mapping)
            @trie = Hanami::API::Middleware::Trie.new(app, "/")

            mapping.each do |prefix, stack|
              builder = Rack::Builder.new

              stack.each do |middleware, args, blk|
                builder.use(middleware, *args, &blk)
              end

              builder.run(app)

              @trie.add(prefix, builder.to_app.freeze)
            end

            @trie.freeze
          end

          def call(env)
            @trie.find(env["PATH_INFO"]).call(env)
          end
        end

        def finalize(app)
          mapping = to_hash
          return app if mapping.empty?

          App.new(app, mapping)
        end

        private

        # @since x.x.x
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
