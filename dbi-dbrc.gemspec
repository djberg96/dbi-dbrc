require 'rubygems'

spec = Gem::Specification.new do |s|
   s.name       = 'dbi-dbrc'
   s.version    = '1.1.6'
   s.author     = 'Daniel Berger'
   s.email      = 'djberg96@gmail.com'
   s.license    = 'Artistic 2.0'
   s.summary    = 'A simple way to avoid hard-coding passwords with DBI'
   s.homepage   = 'http://www.rubyforge.org/projects/shards'
   s.platform   = Gem::Platform::RUBY
   s.files      = Dir['**/*'].reject{ |f| f.include?('CVS') }
   s.test_files = Dir['test/test*.rb']
   s.has_rdoc   = true

   s.extra_rdoc_files  = ['README', 'CHANGES', 'MANIFEST']
   s.rubyforge_project = 'shards'

   s.add_dependency('sys-admin', '>= 1.5.2')
   s.add_development_dependency('test-unit')

   if Config::CONFIG['host_os'] =~ /mswin|win32|dos/i
      s.add_dependency('win32-file', '>= 0.4.2')
      s.add_dependency('win32-dir', '>= 0.3.0')
      s.add_dependency('win32-process', '>= 0.6.1')
      s.platform = Gem::Platform::CURRENT
   end

   s.description = <<-EOF
      The dbi-dbrc library provides an interface for storing database
      connection information, including passwords, in a locally secure
      file only accessible by you, or root. This allows you to avoid
      hard coding login and password information in your programs
      that require such information.

      This library can also be used to store login and password information
      for logins on remote hosts, not just databases.
   EOF
end

Gem::Builder.new(spec).build
