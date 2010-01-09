require 'rake'
require 'rake/testtask'

desc "Install the dbi-dbrc package (non-gem)"
task :install do
   dest = File.join(Config::CONFIG['sitelibdir'], 'dbi')
   Dir.mkdir(dest) unless File.exists? dest
   cp 'lib/dbi/dbrc.rb', dest, :verbose => true
end

desc "Install the dbi-dbrc package as a gem"
task :install_gem do
   ruby 'dbi-dbrc.gemspec'
   file = Dir["*.gem"].first
   sh "gem install #{file}"
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
