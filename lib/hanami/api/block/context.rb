# frozen_string_literal: true

require "hanami/router/block"
require "rack/utils"
require "json"

module Hanami
  class API
    module Block
      # Execution context for Block syntax
      #
      # @since 0.1.0
      class Context < Hanami::Router::Block::Context
        # @overload body
        #   Gets the current HTTP response body
        #   @return [String] the HTTP body
        # @overload body(value)
        #   Sets the HTTP body
        #   @param value [String] the HTTP response body
        #
        # @since 0.1.0
        def body(value = nil)
          if value
            @body = value
          else
            @body
          end
        end

        # Halts the flow of the block and immediately returns with the current
        # HTTP status
        #
        # @param status [Integer] a valid HTTP status code
        # @param body [String] an optional HTTP response body
        #
        # @example HTTP Status
        #   get "/authenticate" do
        #     halt(401)
        #
        #     # this code will never be reached
        #   end
        #
        #   # It sets a Rack response: [401, {}, ["Unauthorized"]]
        #
        # @example HTTP Status and body
        #   get "/authenticate" do
        #     halt(401, "You shall not pass")
        #
        #     # this code will never be reached
        #   end
        #
        #   # It sets a Rack response: [401, {}, ["You shall not pass"]]
        #
        # @since 0.1.0
        def halt(status, body = nil)
          body ||= http_status(status)
          throw :halt, [status, body]
        end

        # Redirects request and immediately halts it
        #
        # @param url [String] the destination URL
        # @param status [Integer] an optional HTTP code for the redirect
        #
        # @see #halt
        #
        # @since 0.1.0
        #
        # @example URL
        #   get "/legacy" do
        #     redirect "/dashboard"
        #
        #     # this code will never be reached
        #   end
        #
        #   # It sets a Rack response: [301, {"Location" => "/new"}, ["Moved Permanently"]]
        #
        # @example URL and HTTP status
        #   get "/legacy" do
        #     redirect "/dashboard", 302
        #
        #     # this code will never be reached
        #   end
        #
        #   # It sets a Rack response: [302, {"Location" => "/new"}, ["Moved"]]
        def redirect(url, status = 301)
          headers["Location"] = url
          halt(status)
        end

        # Utility for redirect back using HTTP request header `HTTP_REFERER`
        #
        # @since 0.1.0
        #
        # @example
        #   get "/authenticate" do
        #     if authenticate(env)
        #       redirect back
        #     else
        #       # ...
        #     end
        #   end
        def back
          env["HTTP_REFERER"] || "/"
        end

        # Sets a JSON response for the given object
        #
        # @param object [Object] a JSON serializable object
        # @param mime [String] optional MIME type to set for the response
        #
        # @since 0.1.0
        #
        # @example JSON serializable object
        #   get "/user/:id" do
        #     user = UserRepository.new.find(params[:id])
        #     json(user)
        #   end
        #
        # @example JSON serializable object and custom MIME type
        #   get "/user/:id" do
        #     user = UserRepository.new.find(params[:id])
        #     json(user, "application/vnd.api+json")
        #   end
        def json(object, mime = "application/json")
          headers["Content-Type"] = mime
          JSON.generate(object)
        end

        # @since 0.1.0
        # @api private
        #
        # rubocop:disable Metrics/MethodLength
        def call
          case caught
            in String => body
            [status, headers, [body]]
            in Integer => status
            # rubocop:disable Style/RedundantSelf
            #
            # NOTE: It must use `self.body` so it will pick the method defined above.
            #
            #       If `self` isn't enforced, Ruby will try to bind `body` to
            #       the current pattern matching context.
            #       When that happens, the body that was manually set is ignored,
            #       which results in a bug.
            [status, headers, [self.body || http_status(status)]]
            # rubocop:enable Style/RedundantSelf
            in [Integer => status, String => body]
            [status, headers, [body]]
            in [Integer => status, Hash => caught_headers, String => body]
            headers.merge!(caught_headers)
            [status, headers, [body]]
          end
        end
        # rubocop:enable Metrics/MethodLength

        private

        # @since 0.1.0
        # @api private
        def caught
          catch :halt do
            instance_exec(&@blk)
          end
        end

        # @since 0.1.0
        # @api private
        def http_status(code)
          Rack::Utils::HTTP_STATUS_CODES.fetch(code)
        end
      end
    end
  end
end
