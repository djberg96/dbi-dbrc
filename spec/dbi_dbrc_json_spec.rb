# frozen_string_literal: true

########################################################################
# dbi_dbrc_json_spec.rb
#
# Test suite for the JSON specific version of DBI::DBRC. This test case
# should be run via the 'rake test' task.
########################################################################
require 'dbi/dbrc'
require 'rspec'
require 'pp' # Need this to avoid fakefs error
require 'fakefs/spec_helpers'

RSpec.describe DBI::DBRC::JSON, :json => true do
  include FakeFS::SpecHelpers

  let(:home) { File.join(Dir.pwd, 'home', 'someone') }
  let(:dbrc) { File.join(home, '.dbrc') }

  let(:db_foo){ 'foo' }
  let(:user1) { 'user1' }

  let(:json){
    %q{
    [
      {
        "foo": {
          "user": "user1",
          "password": "pwd1",
          "driver": "Oracle",
          "interval": 60,
          "timeout": 40,
          "maximum_reconnects": 3
        }
      },
      {
        "foo": {
          "user": "user2",
          "password": "pwd2",
          "driver": "OCI8",
          "interval": 60,
          "timeout": 60,
          "maximum_reconnects": 4
        }
      },
      {
        "bar": {
          "user": "user1",
          "password": "pwd3",
          "driver": "Oracle",
          "interval": 30,
          "timeout": 30,
          "maximum_reconnects": 2
        }
      },
      {
        "baz": {
          "user": "user3",
          "password": "pwd4"
        }
      }
    ]
    }
  }

  before do
    allow(Dir).to receive(:home).and_return(home)

    if File::ALT_SEPARATOR
      allow(FakeFS::File).to receive(:hidden?).and_return(true)
      allow(FakeFS::File).to receive(:encrypted?).and_return(false)
    end

    FileUtils.mkdir_p(home)
    File.write(dbrc, json)
    File.chmod(0600, dbrc)

    # FakeFS doesn't implement this yet
    allow_any_instance_of(FakeFS::File::Stat).to receive(:owned?).and_return(true)
  end

  context 'instance methods' do
    before do
      @dbrc = described_class.new(db_foo, user1)
    end

    example 'database method returns expected value' do
      expect(@dbrc.database).to eq('foo')
    end

    example 'password method returns expected value' do
      expect(@dbrc.password).to eq('pwd1')
    end

    example 'driver method returns expected value' do
      expect(@dbrc.driver).to eq('Oracle')
    end

    example 'interval method returns expected value' do
      expect(@dbrc.interval).to eq(60)
    end

    example 'timeout method returns expected value' do
      expect(@dbrc.timeout).to eq(40)
    end

    example 'maximum_reconnects method returns expected value' do
      expect(@dbrc.maximum_reconnects).to eq(3)
    end
  end
end
