require 'rubygems'

Gem::Specification.new do |spec|
  spec.name       = 'dbi-dbrc'
  spec.version    = '1.4.1'
  spec.author     = 'Daniel Berger'
  spec.email      = 'djberg96@gmail.com'
  spec.license    = 'Apache-2.0'
  spec.summary    = 'A simple way to avoid hard-coding passwords with DBI'
  spec.homepage   = 'https://github.com/djberg96/dbi-dbrc'
  spec.files      = Dir['**/*'].reject{ |f| f.include?('git') }
  spec.test_files = Dir['test/test*.rb']
  spec.cert_chain = Dir['certs/*']

  spec.extra_rdoc_files = ['README', 'CHANGES', 'MANIFEST']

  spec.required_ruby_version = ">= 1.9.3"

  spec.add_development_dependency('test-unit')
  spec.add_development_dependency('rake')

  spec.metadata = {
    'homepage_uri'      => 'https://github.com/djberg96/dbi-dbrc',
    'bug_tracker_uri'   => 'https://github.com/djberg96/dbi-dbrc/issues',
    'changelog_uri'     => 'https://github.com/djberg96/dbi-dbrc/blob/master/CHANGES',
    'documentation_uri' => 'https://github.com/djberg96/dbi-dbrc/wiki',
    'source_code_uri'   => 'https://github.com/djberg96/dbi-dbrc',
    'wiki_uri'          => 'https://github.com/djberg96/dbi-dbrc/wiki'
  }

  if File::ALT_SEPARATOR
    spec.add_dependency('sys-admin')
    spec.add_dependency('win32-file-attributes')
    spec.add_dependency('win32-dir')
    spec.add_dependency('win32-process')
    spec.platform = Gem::Platform::CURRENT
    spec.platform.cpu = 'universal'
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
