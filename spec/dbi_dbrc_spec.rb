# frozen_string_literal: true

#########################################################################
# dbi_dbrc_spec.rb
#
# Specs for the base class of DBI::DBRC. This test case should be
# run via the 'rake spec' task.
#########################################################################
require 'dbi/dbrc'
require 'fileutils'
require 'spec_helper'
require 'pp' # Requiring this ahead of fakefs to address a superclass issue.
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
  let(:db_baz){ 'baz' }
  let(:user1) { 'user1' }
  let(:user2) { 'user2' }

  before do
    allow(Dir).to receive(:home).and_return(home)
    FileUtils.mkdir_p(home)
    File.write(dbrc, plain)
    File.chmod(0600, dbrc)

    # FakeFS doesn't implement this yet
    allow_any_instance_of(FakeFS::File::Stat).to receive(:owned?).and_return(true)
  end

  example 'version' do
    expect(described_class::VERSION).to eq('1.7.0')
    expect(described_class::VERSION).to be_frozen
  end

  context 'windows', :windows do
    example 'constructor raises an error unless the .dbrc file is hidden' do
      allow(FakeFS::File).to receive(:hidden?).and_return(false)
      expect{ described_class.new(db_foo, user1) }.to raise_error(described_class::Error)
    end
  end

  context 'constructor' do
    before do
      if File::ALT_SEPARATOR
        allow(FakeFS::File).to receive(:hidden?).and_return(true)
        allow(FakeFS::File).to receive(:encrypted?).and_return(false)
      end
    end

    example 'constructor raises an error if the permissions are invalid', :unix do
      File.chmod(0555, dbrc)
      expect{ described_class.new(db_foo, user1) }.to raise_error(described_class::Error)
    end

    example 'constructor raises an error if no database is provided' do
      expect{ described_class.new }.to raise_error(ArgumentError)
    end

    example 'constructor works as expected with or without user' do
      expect{ described_class.new(db_foo, user1) }.not_to raise_error
      expect{ described_class.new(db_foo, nil) }.not_to raise_error
    end

    example "constructor fails if the database entry doesn't exist" do
      expect{ described_class.new('bogus', user1) }.to raise_error(DBI::DBRC::Error)
    end

    example "constructor fails if the user entry doesn't exist" do
      expect{ described_class.new(db_foo, 'nobody') }.to raise_error(DBI::DBRC::Error)
    end

    example "constructor fails if the .dbrc file isn't found in the specified directory" do
      expect{ described_class.new(db_foo, user1, '/bogusXX') }.to raise_error(DBI::DBRC::Error)
    end

    example 'constructor returns expected values for the same database with different users' do
      dbrc1 = described_class.new(db_foo, user1)
      dbrc2 = described_class.new(db_foo, user2)
      expect(dbrc1.database).to eq(dbrc2.database)
      expect(dbrc1.user).to eq('user1')
      expect(dbrc2.user).to eq('user2')
    end

    example 'constructor returns expected values for the same user with different database' do
      dbrc1 = described_class.new(db_foo, user1)
      dbrc2 = described_class.new(db_bar, user1)
      expect(dbrc1.user).to eq(dbrc2.user)
      expect(dbrc1.database).to eq('foo')
      expect(dbrc2.database).to eq('bar')
    end

    example 'constructor works as expected if some optional fields are not defined' do
      dbrc = described_class.new(db_baz)
      expect(dbrc.user).to eq('user3')
      expect(dbrc.passwd).to eq('pwd4')
      expect(dbrc.driver).to be_nil
      expect(dbrc.interval).to be_nil
      expect(dbrc.timeout).to be_nil
      expect(dbrc.max_reconn).to be_nil
      expect(dbrc.dsn).to be_nil
    end
  end

  context 'instance methods' do
    before do
      if File::ALT_SEPARATOR
        allow(FakeFS::File).to receive(:hidden?).and_return(true)
        allow(FakeFS::File).to receive(:encrypted?).and_return(false)
      end
      @dbrc = described_class.new(db_foo)
    end

    example 'basic database getter method and aliases' do
      expect(@dbrc).to respond_to(:database)
      expect(@dbrc.method(:database)).to eq(@dbrc.method(:db))
      expect(@dbrc.method(:database)).to eq(@dbrc.method(:host))
    end

    example 'basic database setter method and alias' do
      expect(@dbrc).to respond_to(:database=)
      expect(@dbrc.method(:database=)).to eq(@dbrc.method(:db=))
    end

    example 'database method returns expected value' do
      expect(@dbrc.database).to eq('foo')
    end

    example 'basic dbrc_dir check' do
      expect(@dbrc).to respond_to(:dbrc_dir)
    end

    example 'dbrc_dir returns the expected value' do
      expect(@dbrc.dbrc_dir).to eq(home)
    end

    example 'basic dbrc_file check' do
      expect(@dbrc).to respond_to(:dbrc_file)
    end

    example 'dbrc_file returns the expected value' do
      expect(File.basename(@dbrc.dbrc_file)).to eq('.dbrc')
    end

    example 'basic dsn getter check' do
      expect(@dbrc).to respond_to(:dsn)
    end

    example 'dsn method returns the expected value' do
      expect(@dbrc.dsn).to eq('dbi:Oracle:foo')
    end

    example 'basic dsn setter check' do
      expect(@dbrc).to respond_to(:dsn=)
    end

    example 'user getter basic check' do
      expect(@dbrc).to respond_to(:user)
    end

    example 'user method returns expected value' do
      expect(@dbrc.user).to eq('user1')
    end

    example 'user setter basic check' do
      expect(@dbrc).to respond_to(:user=)
    end

    example 'password getter basic check and alias' do
      expect(@dbrc).to respond_to(:password)
      expect(@dbrc.method(:password)).to eq(@dbrc.method(:passwd))
    end

    example 'password method returns expected value' do
      expect(@dbrc.password).to eq('pwd1')
    end

    example 'password setter basic check and alias' do
      expect(@dbrc).to respond_to(:password=)
      expect(@dbrc.method(:password=)).to eq(@dbrc.method(:passwd=))
    end

    example 'driver getter basic check' do
      expect(@dbrc).to respond_to(:driver)
    end

    example 'driver method returns expected value' do
      expect(@dbrc.driver).to eq('Oracle')
    end

    example 'driver setter basic check' do
      expect(@dbrc).to respond_to(:driver=)
    end

    example 'interval getter basic check' do
      expect(@dbrc).to respond_to(:interval)
    end

    example 'interval method returns expected value' do
      expect(@dbrc.interval).to eq(60)
    end

    example 'interval setter basic check' do
      expect(@dbrc).to respond_to(:interval=)
    end

    example 'timeout getter basic check' do
      expect(@dbrc).to respond_to(:timeout)
      expect(@dbrc.method(:timeout)).to eq(@dbrc.method(:time_out))
    end

    example 'timeout method returns expected value' do
      expect(@dbrc.timeout).to eq(40)
    end

    example 'timeout setter basic check' do
      expect(@dbrc).to respond_to(:timeout=)
    end

    example 'max_reconn getter basic check' do
      expect(@dbrc).to respond_to(:max_reconn)
      expect(@dbrc.method(:max_reconn)).to eq(@dbrc.method(:maximum_reconnects))
    end

    example 'max_reconn method returns expected value' do
      expect(@dbrc.max_reconn).to eq(3)
    end

    example 'max_reconn setter basic check' do
      expect(@dbrc).to respond_to(:max_reconn=)
    end
  end
end
