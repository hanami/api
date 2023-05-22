require "rake"
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |task|
  file_list = FileList["spec/**/*_spec.rb"]

  task.pattern = file_list
end

task default: "spec"
