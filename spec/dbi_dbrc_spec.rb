#########################################################################
# dbi_dbrc_spec.rb
#
# Specs for the base class of DBI::DBRC. This test case should be
# run via the 'rake spec' task.
#########################################################################
require 'dbi/dbrc'
require 'fileutils'
require 'spec_helper'
require 'fakefs/spec_helpers'

RSpec.describe DBI::DBRC do
  include FakeFS::SpecHelpers

  let(:windows) { File::ALT_SEPARATOR }
  let(:home) { File.join(Dir.pwd, 'home', 'someone') }
  let(:dbrc) { File.join(home, '.dbrc') }

  let(:plain) {
    %q{
      foo      user1    pwd1     Oracle   40       3     60
      foo      user2    pwd2     OCI8     60       4     60
      bar      user1    pwd3     Oracle   30       2     30
      baz      user3    pwd4
    }.lstrip
  }

  let(:db_foo){ 'foo' }
  let(:db_bar){ 'bar' }
  let(:user1) { 'user1' }
  let(:user2) { 'user2' }

  before do
    allow(Dir).to receive(:home).and_return(home)
    FileUtils.mkdir_p(home)
    File.open(dbrc, 'w'){ |fh| fh.write(plain) }
    File.chmod(0600, dbrc)
  end

=begin
  before do
    @dir      = File.join(Dir.pwd, 'examples/plain')
    @file     = File.join(@dir, '.dbrc')
    @db1      = 'foo'
    @db2      = 'bar'
    @user1    = 'user1'
    @user2    = 'user2'
    @db_bad   = 'blah'  # Doesn't exist
    @user_bad = 'user8' # Doesn't exist

    if @@windows && File.respond_to?(:set_attr)
      File.set_attr(@file, File::HIDDEN)
    else
      File.chmod(0600, @file)
    end

    @dbrc = DBRC.new(@db1, nil, @dir)
  end
=end

  example "version" do
    expect(described_class::VERSION).to eq('1.5.0')
    expect(described_class::VERSION).to be_frozen
  end

  context "windows", :windows => true do
    example "constructor raises an error unless the .dbrc file is hidden" do
      File.unset_attr(plain, File::HIDDEN)
      expect{ described_class.new(db_foo, user1) }.to raise_error(described_class::Error)
    end
  end

  context "constructor" do
    before do
      # FakeFS doesn't implement this yet
      allow_any_instance_of(FakeFS::File::Stat).to receive(:owned?).and_return(true)
    end

    example "constructor raises an error if the permissions are invalid" do
      File.chmod(0555, dbrc)
      expect{ described_class.new(db_foo, user1) }.to raise_error(described_class::Error)
    end

    example "constructor raises an error if no database is provided" do
      expect{ described_class.new }.to raise_error(ArgumentError)
    end

    example "constructor works as expected with or without user" do
      expect{ described_class.new(db_foo, user1) }.not_to raise_error
      expect{ described_class.new(db_foo, nil) }.not_to raise_error
    end
  end

  #example "constructor" do
  #end

=begin
  example "bad_database" do
    expect{ DBRC.new(@db_bad, nil, @dir) }.to raise_error(DBRC::Error)
  end

  example "bad_user" do
    expect{ DBRC.new(@db1, @user_bad, @dir) }.to raise_error(DBRC::Error)
  end

  example "bad_dir" do
    expect{ described_class.new(@db1, @user1, '/bogusXX') }.to raise_error(described_class::Error)
  end

  example "database" do
    expect(@dbrc).to respond_to(:database)
    expect(@dbrc).to respond_to(:database=)
    expect(@dbrc).to respond_to(:db)
    expect(@dbrc).to respond_to(:db=)
    expect( @dbrc.db).to be_kind_of(String)
  end

  example "host_alias" do
    expect(@dbrc).to respond_to(:host)
    expect( @dbrc.method(:host) == @dbrc.method(:database)).to eq(true)
  end

  example "dbrc_dir" do
    expect(@dbrc).to respond_to(:dbrc_dir)
    expect( @dbrc.dbrc_dir).to eq(@dir)
  end

  example "dbrc_file" do
    expect(@dbrc).to respond_to(:dbrc_file)
    expect( File.basename(@dbrc.dbrc_file)).to eq('.dbrc')
  end

  example "dsn" do
    expect(@dbrc).to respond_to(:dsn)
    expect(@dbrc).to respond_to(:dsn=)
  end

  example "user" do
    expect(@dbrc).to respond_to(:user)
    expect(@dbrc).to respond_to(:user=)
    expect( @dbrc.user).to be_kind_of(String)
  end

  example "password" do
    expect(@dbrc).to respond_to(:password)
    expect(@dbrc).to respond_to(:password=)
    expect(@dbrc).to respond_to(:passwd)
    expect(@dbrc).to respond_to(:passwd=)
    expect( @dbrc.password).to be_kind_of(String)
  end

  example "driver" do
    expect(@dbrc).to respond_to(:driver)
    expect(@dbrc).to respond_to(:driver=)
    expect( @dbrc.driver).to be_kind_of(String)
  end

  example "interval" do
    expect(@dbrc).to respond_to(:interval)
    expect(@dbrc).to respond_to(:interval=)
    expect( @dbrc.interval).to be_kind_of(Numeric)
  end

  example "timeout" do
    expect(@dbrc).to respond_to(:timeout)
    expect(@dbrc).to respond_to(:timeout=)
    expect(@dbrc).to respond_to(:time_out)
    expect(@dbrc).to respond_to(:time_out=)
    expect( @dbrc.timeout).to be_kind_of(Numeric)
  end

  example "max_reconn" do
    expect(@dbrc).to respond_to(:max_reconn)
    expect(@dbrc).to respond_to(:max_reconn=)
    expect(@dbrc).to respond_to(:maximum_reconnects)
    expect(@dbrc).to respond_to(:maximum_reconnects=)
    expect( @dbrc.maximum_reconnects).to be_kind_of(Numeric)
  end

  example "sample_values" do
    expect( @dbrc.database).to eq("foo")
    expect( @dbrc.user).to eq("user1")
    expect( @dbrc.passwd).to eq("pwd1")
    expect( @dbrc.driver).to eq("Oracle")
    expect( @dbrc.interval).to eq(60)
    expect( @dbrc.timeout).to eq(40)
    expect( @dbrc.max_reconn).to eq(3)
    expect( @dbrc.dsn).to eq("dbi:Oracle:foo")
  end

  # Same database, different user
  example "duplicate_database" do
    db = DBRC.new("foo", "user2", @dir)
    expect( db.user).to eq("user2")
    expect( db.passwd).to eq("pwd2")
    expect( db.driver).to eq("OCI8")
    expect( db.interval).to eq(60)
    expect( db.timeout).to eq(60)
    expect( db.max_reconn).to eq(4)
    expect( db.dsn).to eq("dbi:OCI8:foo")
  end

  # Different database, different user
  example "different_database" do
    db = DBRC.new("bar", "user1", @dir)
    expect( db.user).to eq("user1")
    expect( db.passwd).to eq("pwd3")
    expect( db.driver).to eq("Oracle")
    expect( db.interval).to eq(30)
    expect( db.timeout).to eq(30)
    expect( db.max_reconn).to eq(2)
    expect( db.dsn).to eq("dbi:Oracle:bar")
  end

  # A database with only a couple fields defined
  example "nil_values" do
    db = DBRC.new("baz", "user3", @dir)
    expect( db.user).to eq("user3")
    expect( db.passwd).to eq("pwd4")
    expect(db.driver).to be_nil
    expect(db.interval).to be_nil
    expect(db.timeout).to be_nil
    expect(db.max_reconn).to be_nil
    expect(db.dsn).to be_nil
  end
=end
end
