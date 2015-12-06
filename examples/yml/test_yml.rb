#######################################################################
# test_yml.rb
#
# Simple test script that uses the DBRC::YML subclass.
#######################################################################
if File.basename(Dir.pwd) == "yml"
  Dir.chdir "../.."
  $LOAD_PATH.unshift Dir.pwd + "/lib"
  Dir.chdir "examples/yml"
end

require "dbi/dbrc"
require "pp"
include DBI

puts "VERSION: " + DBRC::YML::VERSION

# Use the .dbrc file in this directory
db1 = DBRC::YML.new("foo",nil,Dir.pwd) # Get first entry found for 'foo'
db2 = DBRC::YML.new("foo","user1",Dir.pwd) # Specify user

puts "First entry found for 'foo': "
pp db1
puts "=" * 20

puts "Entry for 'foo' with user 'bar': "
pp db2
puts "=" * 20
