require 'rake'
require 'rake/clean'
require 'rspec/core/rake_task'

CLEAN.include("**/*.gem", "**/*.rbc")

namespace :gem do
  desc "Create the dbi-dbrc gem"
  task :create => [:clean] do
    require 'rubygems/package'
    spec = eval(IO.read('dbi-dbrc.gemspec'))
    spec.signing_key = File.join(Dir.home, '.ssh', 'gem-private_key.pem')
    Gem::Package.build(spec, true)
  end

  desc "Install the dbi-dbrc gem"
  task :install => [:create] do
    gem = Dir["*.gem"].first
    sh "gem install -l #{gem}"
  end
end

desc "Run the test suite"
RSpec::Core::RakeTask.new(:spec)

task :default => :spec
