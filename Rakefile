require 'rake'
require 'rake/clean'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

CLEAN.include("**/*.gem", "**/*.rbc", "**/*.lock")

namespace :gem do
  desc "Create the dbi-dbrc gem"
  task :create => [:clean] do
    require 'rubygems/package'
    spec = Gem::Specification.load('dbi-dbrc.gemspec')
    spec.signing_key = File.join(Dir.home, '.ssh', 'gem-private_key.pem')
    Gem::Package.build(spec)
  end

  desc "Install the dbi-dbrc gem"
  task :install => [:create] do
    gem = Dir["*.gem"].first
    sh "gem install -l #{gem}"
  end
end

RuboCop::RakeTask.new

desc "Run the test suite"
RSpec::Core::RakeTask.new(:spec)

# Clean up afterwards
Rake::Task[:spec].enhance do
  Rake::Task[:clean].invoke
end

task :default => :spec
