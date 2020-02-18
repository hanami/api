# frozen_string_literal: true

require "rack/builder"

module Hanami
  class API
    # Hanami::API middleware stack
    #
    # @since x.x.x
    # @api private
    module Middleware
      # Middleware stack
      #
      # @since x.x.x
      # @api private
      class Stack
        # @since x.x.x
        # @api private
        ROOT_PREFIX = "/"
        private_constant :ROOT_PREFIX

        # @since x.x.x
        # @api private
        def initialize
          @prefix = ROOT_PREFIX
          @stack = Hash.new { |hash, key| hash[key] = [] }
        end

        # @since x.x.x
        # @api private
        def use(middleware, args, &blk)
          @stack[@prefix].push([middleware, args, blk])
        end

        # @since x.x.x
        # @api private
        def with(path)
          prefix = @prefix
          @prefix = path
          yield
        ensure
          @prefix = prefix
        end

        # @since x.x.x
        # @api private
        def finalize(app) # rubocop:disable Metrics/MethodLength
          uniq!
          return app if @stack.empty?

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
          end
        end

        # @since x.x.x
        # @api private
        def each(&blk)
          uniq!
          @stack.each(&blk)
        end

        # @since x.x.x
        # @api private
        def mapped(builder, prefix, &blk)
          if prefix == ROOT_PREFIX
            builder.instance_eval(&blk)
          else
            builder.map(prefix, &blk)
          end
        end

        private

        # @since x.x.x
        # @api private
        def uniq!
          @stack.each_value(&:uniq!)
        end
      end
    end
  end
end
