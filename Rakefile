require "bundler/gem_tasks"
require "rspec/core/rake_task"

# run tests with `rake spec`
RSpec::Core::RakeTask.new :spec do |task|
  task.rspec_opts = ["--color", "--format=doc", "--format=Nc"]
end

task default: :spec

desc "Update and publish docs to gh-pages"
task :docs do |task|
  `yard docs`
  `ghp-import -p doc`
end

task :build_rpm do
end
