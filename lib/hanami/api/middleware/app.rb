# frozen_string_literal: true

require "rack/builder"

module Hanami
  class API
    module Middleware
      # Hanami::API middleware stack
      #
      # @since 0.1.1
      # @api private
      class App
        # @since 0.1.1
        # @api private
        def initialize(app, prefix, mapping)
          @trie = Hanami::API::Middleware::Trie.new(app, prefix)

          mapping.each do |path, stack|
            builder = Rack::Builder.new

            stack.each do |middleware, args, blk|
              builder.use(middleware, *args, &blk)
            end

            builder.run(app)

            @trie.add(path, builder.to_app.freeze)
          end

          @trie.freeze
        end

        # @since 0.1.1
        # @api private
        def call(env)
          @trie.find(env["PATH_INFO"]).call(env)
        end
      end
    end
  end
end
