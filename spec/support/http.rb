# frozen_string_literal: true

module RSpec
  module Support
    module HTTP
      SUPPORTED_METHODS = %w[get post patch put delete trace options link unlink].freeze
      private_constant :SUPPORTED_METHODS

      def self.supported_methods
        SUPPORTED_METHODS
      end
    end
  end
end
