# frozen_string_literal: true

########################################################################
# dbi_dbrc_xml_spec.rb
#
# Test suite for the XML specific version of DBI::DBRC. This test case
# should be run via the 'rake test' task.
########################################################################
require 'dbi/dbrc'
require 'rspec'
require 'pp' # Need this to avoid fakefs error
require 'fakefs/spec_helpers'

RSpec.describe DBI::DBRC::XML, :xml => true do
  include FakeFS::SpecHelpers

  let(:home) { File.join(Dir.pwd, 'home', 'someone') }
  let(:dbrc) { File.join(home, '.dbrc') }

  let(:db_foo){ 'foo' }
  let(:user1) { 'user1' }

  let(:xml){
    %q{
      <dbrc>
         <database name="foo">
            <user>user1</user>
            <password>pwd1</password>
            <driver>Oracle</driver>
            <interval>60</interval>
            <timeout>40</timeout>
            <maximum_reconnects>3</maximum_reconnects>
         </database>
         <database name="foo">
            <user>user2</user>
            <password>pwd2</password>
            <driver>OCI8</driver>
            <interval>60</interval>
            <timeout>60</timeout>
            <maximum_reconnects>4</maximum_reconnects>
         </database>
         <database name="bar">
            <user>user1</user>
            <password>pwd3</password>
            <driver>Oracle</driver>
            <interval>30</interval>
            <timeout>30</timeout>
            <maximum_reconnects>2</maximum_reconnects>
         </database>
         <database name="baz">
            <user>user3</user>
            <password>pwd4</password>
         </database>
      </dbrc>
    }.lstrip
  }

  before do
    allow(Dir).to receive(:home).and_return(home)

    if File::ALT_SEPARATOR
      allow(FakeFS::File).to receive(:hidden?).and_return(true)
      allow(FakeFS::File).to receive(:encrypted?).and_return(false)
    end

    FileUtils.mkdir_p(home)
    File.write(dbrc, xml)
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
