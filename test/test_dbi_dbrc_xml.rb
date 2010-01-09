########################################################################
# test_dbi_dbrc_xml.rb
#
# Test suite for the XML specific version of DBI::DBRC. This test case
# should be run via the 'rake test' task.
########################################################################
require 'rubygems'
gem 'test-unit'

require 'dbi/dbrc'
require 'test/unit'
require 'rexml/document'
include REXML
include DBI

class TC_DBI_DBRC_XML < Test::Unit::TestCase
   def setup
      @dir      = File.join(Dir.pwd, 'examples/xml')
      @file     = File.join(@dir, '.dbrc')
      @db1      = "foo"
      @db2      = "bar"
      @user1    = "user1"
      @user2    = "user2"
      @db_bad   = "blah"  # Doesn't exist
      @user_bad = "user8" # Doesn't exist

      if File::ALT_SEPARATOR && File.respond_to?(:set_attr)
         File.set_attr(@file, File::HIDDEN)
      else
         File.chmod(0600, @file)
      end
      
      @dbrc = DBRC::XML.new(@db1, nil, @dir)
   end

   def test_constructor
      assert_raises(ArgumentError){ DBRC::XML.new }
      assert_nothing_raised{ DBRC::XML.new(@db1, @user1, @dir) }
      assert_nothing_raised{ DBRC::XML.new(@db1, nil, @dir) }
   end

   def test_bad_database
      assert_raises(DBRC::Error){ DBRC::XML.new(@db_bad, nil, @dir) }
   end

   def test_bad_user
      assert_raises(DBRC::Error){ DBRC::XML.new(@db1, @user_bad, @dir) }
   end

   def test_database
      assert_respond_to(@dbrc, :database)
      assert_respond_to(@dbrc, :database=)
      assert_respond_to(@dbrc, :db)
      assert_respond_to(@dbrc, :db=)
      assert_kind_of(String, @dbrc.db)
   end

   def test_dsn
      assert_respond_to(@dbrc, :dsn)
      assert_respond_to(@dbrc, :dsn=)
   end

   def test_user
      assert_respond_to(@dbrc, :user)
      assert_respond_to(@dbrc, :user=)
      assert_kind_of(String, @dbrc.user)
   end

   def test_password
      assert_respond_to(@dbrc, :password)
      assert_respond_to(@dbrc, :password=)
      assert_respond_to(@dbrc, :passwd)
      assert_respond_to(@dbrc, :passwd=)
      assert_kind_of(String, @dbrc.password)
   end

   def test_driver
      assert_respond_to(@dbrc, :driver)
      assert_respond_to(@dbrc, :driver=)
      assert_kind_of(String, @dbrc.driver)
   end

   def test_interval
      assert_respond_to(@dbrc, :interval)
      assert_respond_to(@dbrc, :interval=)
      assert_kind_of(Fixnum, @dbrc.interval)
   end

   def test_timeout
      assert_respond_to(@dbrc, :timeout)
      assert_respond_to(@dbrc, :timeout=)
      assert_respond_to(@dbrc, :time_out)
      assert_respond_to(@dbrc, :time_out=)
      assert_kind_of(Fixnum, @dbrc.timeout)
   end

   def test_max_reconn
      assert_respond_to(@dbrc, :max_reconn)
      assert_respond_to(@dbrc, :max_reconn=)
      assert_respond_to(@dbrc, :maximum_reconnects)
      assert_respond_to(@dbrc, :maximum_reconnects=)
      assert_kind_of(Fixnum, @dbrc.maximum_reconnects)
   end

   def test_sample_values
      assert_equal("foo", @dbrc.database)
      assert_equal("user1", @dbrc.user)
      assert_equal("pwd1", @dbrc.passwd)
      assert_equal("Oracle", @dbrc.driver)
      assert_equal(60, @dbrc.interval)
      assert_equal(40, @dbrc.timeout)
      assert_equal(3, @dbrc.max_reconn)
      assert_equal("dbi:Oracle:foo", @dbrc.dsn)
   end

   # Same database, different user
   def test_duplicate_database
      db = DBRC::XML.new("foo", "user2", @dir) 
      assert_equal("user2", db.user)
      assert_equal("pwd2", db.passwd)
      assert_equal("OCI8", db.driver)
      assert_equal(60, db.interval)
      assert_equal(60, db.timeout)
      assert_equal(4, db.max_reconn)
      assert_equal("dbi:OCI8:foo", db.dsn)
   end

   # Different database, different user
   def test_different_database
      db = DBRC::XML.new("bar", "user1", @dir)
      assert_equal("user1", db.user)
      assert_equal("pwd3", db.passwd)
      assert_equal("Oracle", db.driver)
      assert_equal(30, db.interval)
      assert_equal(30, db.timeout)
      assert_equal(2, db.max_reconn)
      assert_equal("dbi:Oracle:bar", db.dsn)
   end

   # A database with only a couple fields defined
   def test_nil_values
      db = DBRC::XML.new("baz", "user3", @dir) 
      assert_equal("user3", db.user)
      assert_equal("pwd4", db.passwd)
      assert_nil(db.driver)
      assert_nil(db.interval)
      assert_nil(db.timeout)
      assert_nil(db.max_reconn)
      assert_nil(db.dsn)
   end

   def teardown
      @dir      = nil
      @db1      = nil
      @db2      = nil
      @user1    = nil
      @user2    = nil
      @db_bad   = nil
      @user_bad = nil
      @dbrc     = nil
   end
end
