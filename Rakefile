require "bundler/gem_tasks"
require "rspec/core/rake_task"

# run tests with `rake spec`
RSpec::Core::RakeTask.new :spec do |task|
  task.rspec_opts = ["--color", "--format=doc", "--format=Nc"]
end

task default: :spec
