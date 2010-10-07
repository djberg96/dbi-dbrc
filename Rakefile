require 'rake'
require 'rake/testtask'

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
  task :install => [:build] do
    gem = Dir["*.gem"].first
    sh "gem install #{gem}"
  end
end

Rake::TestTask.new do |t|
  t.warning = true
  t.verbose = true
end

Rake::TestTask.new(:test_xml) do |t|
  t.warning = true
  t.verbose = true
  t.test_files = FileList['test/test_dbi_dbrc_xml.rb']
end

Rake::TestTask.new(:test_yml) do |t|
  t.warning = true
  t.verbose = true
  t.test_files = FileList['test/test_dbi_dbrc_yml.rb']
end

task :default => :test
