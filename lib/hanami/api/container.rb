# frozen_string_literal: true

begin
  require "dry/container"
  require "dry/auto_inject"
rescue LoadError
  puts "Hanami::API::Container requires `dry-container' and `dry-auto_inject' gems. Add them to your `Gemfile'."
  raise
end

module Hanami
  class API
    module Container
      def self.extended(app)
        super
        container = Class.new(Dry::Container) do
          extend Dry::Container::Mixin
        end

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
