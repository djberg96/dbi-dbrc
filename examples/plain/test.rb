###########################################################################
# test.rb
#
# This script is provided for those without TestUnit installed and/or for
# general futzing.
###########################################################################
if File.basename(Dir.pwd) == "plain"
   Dir.chdir "../.."
   $LOAD_PATH.unshift Dir.pwd + "/lib"
   Dir.chdir "examples/plain"
end

require "pp"
require "dbi/dbrc"
include DBI

puts "VERSION: " + DBRC::VERSION

db = DBRC.new("foo","user1",Dir.pwd)

pp db
