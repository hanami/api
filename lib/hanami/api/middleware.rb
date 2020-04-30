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
          @_stack = Trie.new(prefix)
          @stack = Hash.new { |hash, key| hash[key] = [] }
        end

        # @since 0.1.0
        # @api private
        def use(prefix, middleware, *args, &blk)
          @_stack.add(prefix, [middleware, args, blk])
          @stack[prefix].push([middleware, args, blk])
        end

        # @since 0.1.0
        # @api private
        def finalize(app) # rubocop:disable Metrics/MethodLength
          s = self

          Rack::Builder.new do
            s.each do |prefix, stack|
              s.mapped(self, prefix) do
                stack.each do |middleware, args, blk|
                  use(middleware, *args, &blk)
                end
              end

              run app
            end
          end.to_app
        end

        # @since 0.1.0
        # @api private
        def each(&blk)
          uniq!
          @_stack.each(&blk)
        end

        # @since 0.1.0
        # @api private
        def empty?
          uniq!
          @_stack.empty?
        end

        # @since 0.1.0
        # @api private
        def mapped(builder, prefix, &blk)
          if prefix == @prefix
            builder.instance_eval(&blk)
          else
            builder.map(prefix, &blk)
          end
        end

        private

        # @since 0.1.0
        # @api private
        def uniq!
          @stack.each_value(&:uniq!)
        end
      end
    end
  end
end
