# frozen_string_literal: true

require "pathname"
require "dry/system/container"
require "dry/system/components"
require "dry/auto_inject"
require "dry/types"

module Hanami
  class API
    module Container
      def self.extended(app)
        super
        container = Class.new(Dry::System::Container) do
          configure do |config|
            config.root Pathname.new(Dir.pwd)
          end

          use :env, inferrer: -> { ENV.fetch("HANAMI_ENV", :development).to_sym }
        end

        types = Module.new { include Dry.Types() }
        app.const_set(:Types, types)
        app.const_set(:Container, container)
        app.const_set(:Deps, Dry::AutoInject(container))
        app.class_eval do
          @container = self::Container
        end

        app.extend(ClassMethods)
        app.include(InstanceMethods)
      end

      module ClassMethods
        attr_reader :container

        def configure(...)
          container.configure(...)
        end

        def settings(&blk)
          container.boot(:settings, from: :system) do
            settings(&blk)
          end
        end

        def register(...)
          container.register(...)
        end
      end

      module InstanceMethods
        def freeze
          container = self.class.container
          deps = self.class::Deps
          block = self.class::BlockContext
          container.finalize!

          block.class_eval do
            include deps[*container.keys]
          end

          super
        end
      end
    end
  end
end
