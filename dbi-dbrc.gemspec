require 'rubygems'

Gem::Specification.new do |spec|
  spec.name       = 'dbi-dbrc'
  spec.version    = '1.1.7'
  spec.author     = 'Daniel Berger'
  spec.email      = 'djberg96@gmail.com'
  spec.license    = 'Artistic 2.0'
  spec.summary    = 'A simple way to avoid hard-coding passwords with DBI'
  spec.homepage   = 'http://www.rubyforge.org/projects/shards'
  spec.files      = Dir['**/*'].reject{ |f| f.include?('git') }
  spec.test_files = Dir['test/test*.rb']

  spec.extra_rdoc_files  = ['README', 'CHANGES', 'MANIFEST']
  spec.rubyforge_project = 'shards'

  spec.add_dependency('sys-admin', '>= 1.5.2')
  spec.add_development_dependency('test-unit')

  if Config::CONFIG['host_os'] =~ /mswin|msdos|win32|mingw|cygwin/i
    spec.add_dependency('win32-file', '>= 0.6.6')
    spec.add_dependency('win32-dir', '>= 0.3.7')
    spec.add_dependency('win32-process', '>= 0.6.2')
    spec.platform = Gem::Platform::CURRENT
  end

  spec.description = <<-EOF
    The dbi-dbrc library provides an interface for storing database
    connection information, including passwords, in a locally secure
    file only accessible by you, or root. This allows you to avoid
    hard coding login and password information in your programs
    that require such information.

    This library can also be used to store login and password information
    for logins on remote hosts, not just databases.
  EOF
end
