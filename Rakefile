require 'rake'
require 'rake/clean'
require 'rake/testtask'

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

namespace :test do
  Rake::TestTask.new(:all) do |t|
    t.warning = true
    t.verbose = true
  end

  Rake::TestTask.new(:xml) do |t|
    t.warning = true
    t.verbose = true
    t.test_files = FileList['test/test_dbi_dbrc_xml.rb']
  end

  Rake::TestTask.new(:yml) do |t|
    t.warning = true
    t.verbose = true
    t.test_files = FileList['test/test_dbi_dbrc_yml.rb']
  end
end

task :default => 'test:all'
