require 'rake'
require 'rake/clean'
require 'rake/testtask'

CLEAN.include("**/*.gem", "**/*.rbc")

namespace :gem do
  desc "Remove any gem files."
  task :clean do
    Dir['*.gem'].each{ |f| File.delete(f) }
  end

  desc "Create the dbi-dbrc gem"
  task :create => [:clean] do
    spec = eval(IO.read('dbi-dbrc.gemspec'))
    Gem::Builder.new(spec).build
  end

  desc "Install the dbi-dbrc gem"
  task :install => [:create] do
    gem = Dir["*.gem"].first
    sh "gem install #{gem}"
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
