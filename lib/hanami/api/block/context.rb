# frozen_string_literal: true

require "hanami/router/block"
require "rack/utils"
require "json"

module Hanami
  class API
    module Block
      class Context < Hanami::Router::Block::Context
        def body(value = nil)
          if value
            @body = value
          else
            @body
          end
        end

        def halt(status, body = nil)
          body ||= http_status(status)
          throw :halt, [status, body]
        end

        def redirect(url, status = 301)
          headers["Location"] = url
          halt(status)
        end

        def back
          env["HTTP_REFERER"] || "/"
        end

        def json(object, mime = "application/json")
          headers["Content-Type"] = mime
          JSON.generate(object)
        end

        def call
          case caught
            in String => body
            [status, headers, [body]]
            in Integer => status
            [status, headers, [self.body || http_status(status)]]
            in [Integer, String] => response
            [response[0], headers, [response[1]]]
            in [Integer, Hash, String] => response
            headers.merge!(response[1])
            [response[0], headers, [response[2]]]
          end
        end

        private

        def caught
          result = nil
          halted = catch :halt do
            result = instance_exec(&@blk)
            nil
          end

          halted || result
        end

        def http_status(code)
          Rack::Utils::HTTP_STATUS_CODES.fetch(code)
        end
      end
    end
  end
end
