#######################################################################
# test_xml.rb
#
# Simple test script that uses the DBRC::XML subclass.
#######################################################################
if File.basename(Dir.pwd) == "xml"
   Dir.chdir "../.."
   $LOAD_PATH.unshift Dir.pwd + "/lib"
   Dir.chdir "examples/xml"
end

require "dbi/dbrc"
require "pp"
include DBI

puts "VERSION: " + DBRC::XML::VERSION

# Use the .dbrc file in this directory
db1 = DBRC::XML.new("foo",nil,Dir.pwd) # Get first entry found for 'foo'
db2 = DBRC::XML.new("foo","user1",Dir.pwd) # Specify user

puts "First entry found for 'foo': "
pp db1
puts "=" * 20

puts "Entry for 'foo' with user 'bar': "
pp db2
puts "=" * 20
