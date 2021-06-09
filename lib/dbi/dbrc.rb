# frozen_string_literal: true

if File::ALT_SEPARATOR
  require 'win32/dir'
  require 'win32/file/attributes'
  require 'win32/process'
else
  require 'etc'
end

# The DBI module serves as a namespace only.
module DBI
  # The DBRC class encapsulates a database resource config file.
  class DBRC
    # This error is raised if anything fails trying to read the config file.
    class Error < StandardError; end

    # The version of the dbi-dbrc library
    VERSION = '1.5.0'

    WINDOWS = File::ALT_SEPARATOR # :no-doc:

    # The database or host to be connected to.
    attr_accessor :database

    alias db database
    alias db= database=
    alias host database
    alias host= database=

    # The user name used for the database or host connection.
    attr_accessor :user

    # The password associated with the database or host.
    attr_accessor :password

    alias passwd password
    alias passwd= password=

    # The driver associated with the database. This is used to internally to
    # construct the DSN.
    attr_accessor :driver

    # Data source name, e.g. "dbi:OCI8:your_database".
    attr_accessor :dsn

    # The maximum number of reconnects a program should make before giving up.
    attr_accessor :maximum_reconnects

    alias max_reconn maximum_reconnects
    alias max_reconn= maximum_reconnects=

    # The timeout, in seconds, for each connection attempt.
    attr_accessor :timeout

    alias time_out timeout
    alias time_out= timeout=

    # The interval, in seconds, between each connection attempt.
    attr_accessor :interval

    # The directory where the .dbrc file is stored.
    attr_accessor :dbrc_dir

    # The full path to the .dbrc file.
    attr_accessor :dbrc_file

    # Returns a new DBI::DBRC object. The contents of the object depend on
    # the arguments passed to the constructor. If only a database name is
    # passed, then the first entry found in the .dbrc file that matches that
    # database is parsed. If a user name is also included, then the first
    # entry that matches both the database and user name is parsed.
    #
    # If a directory is passed as the third argument, then DBRC will look
    # in that directory, instead of the default directory, for the .dbrc
    # file.
    #
    # If an entry cannot be found for the database, or database plus user
    # combination, then a Error is raised. If the .dbrc file cannot be
    # found, or is setup improperly with regards to permissions or properties
    # then a DBI::DBRC::Error is raised.
    #
    # See the README for the rules regarding .dbrc files and permissions.
    #
    # Note that this library can also be used as a general password
    # storage mechanism. In that case simply treat the 'database' as the
    # host name, and ignore the DBI::DBRC#dsn and DBI::DBRC#driver methods.
    #
    # Examples:
    #
    #   # Find the first match for 'some_database'
    #   DBI::DBRC.new('some_database')
    #
    #   # Find the first match for 'foo_user@some_database'
    #   DBI::DBRC.new('some_database', 'foo_user')
    #
    #   # Find the first match for 'foo_user@some_database' under /usr/local
    #   DBI::DBRC.new('some_database', 'foo_usr', '/usr/local')
    #
    def initialize(database, user = nil, dbrc_dir = Dir.home)
      if dbrc_dir.nil?
        # Default to the app data directory on Windows, or root on Unix, if
        # no home dir can be found.
        if home.nil?
          if WINDOWS
            home = Dir::APPDATA
          else
            home = '/'
          end
        end

        @dbrc_file = File.join(home, '.dbrc')
        dbrc_dir = home
      else
        raise Error, 'bad directory' unless File.directory?(dbrc_dir)
        @dbrc_file = File.join(dbrc_dir, '.dbrc')
      end

      @dbrc_dir  = dbrc_dir
      @database  = database
      @user      = user

      file_was_encrypted = false # Win32 only

      @driver   = nil
      @interval = nil
      @timeout  = nil
      @maximum_reconnects = nil

      check_file()

      # Decrypt and re-encrypt the file if we're on MS Windows and the
      # file is encrypted.
      begin
        if WINDOWS && File.encrypted?(@dbrc_file)
          file_was_encrypted = true
          File.decrypt(@dbrc_file)
        end

        parse_dbrc_config_file()
        validate_data()
        convert_numeric_strings()
        create_dsn_string()
      ensure
        File.encrypt(@dbrc_file) if WINDOWS && file_was_encrypted
      end
    end

    # Inspection of the DBI::DBRC object. This is identical to the standard
    # Ruby Object#inspect, except that the password field is filtered.
    #
    def inspect
      str = instance_variables.map do |iv|
        if iv == '@password'
          "#{iv}=[FILTERED]"
        else
          "#{iv}=#{instance_variable_get(iv).inspect}"
        end
      end.join(', ')

      "#<#{self.class}:0x#{(object_id * 2).to_s(16)} " << str << '>'
    end

    private

    # Ensure that the user/password has been set
    def validate_data
      raise Error, "no user found associated with #{@database}" unless @user
      raise Error, "password not defined for #{@user}@#{@database}" unless @password
    end

    # Converts strings that should be numbers into actual numbers
    def convert_numeric_strings
      @interval   = @interval.to_i if @interval
      @timeout    = @timeout.to_i if @timeout
      @maximum_reconnects = @maximum_reconnects.to_i if @maximum_reconnects
    end

    # Create the dsn string if the driver is defined
    def create_dsn_string
      @dsn = "dbi:#{@driver}:#{@database}" if @driver
    end

    # Check ownership and permissions
    def check_file(file = @dbrc_file)
      File.open(file) do |f|
        # Permissions must be set to 600 or better on Unix systems.
        # Must be hidden on Win32 systems.
        if WINDOWS
          raise Error, 'The .dbrc file must be hidden' unless File.hidden?(file)
        else
          raise Error, 'Bad .dbrc file permissions' unless (f.stat.mode & 0o77) == 0
        end

        # Only the owner may use it
        raise Error, 'Not owner of .dbrc file' unless f.stat.owned?
      end
    end

    # Parse the text out of the .dbrc file.  This is the only method you
    # need to redefine if writing your own config handler.
    def parse_dbrc_config_file(file = @dbrc_file)
      File.foreach(file) do |line|
        next if line =~ /^#/ # Ignore comments
        db, user, pwd, driver, timeout, max, interval = line.split

        next unless @database == db
        next if @user && @user != user

        @user               = user
        @password           = pwd
        @driver             = driver
        @timeout            = timeout
        @maximum_reconnects = max
        @interval           = interval
        break
      end

      if @user
        raise Error, "no record found for #{@user}@#{@database}" unless @user
      else
        raise Error, "no record found for #{@database}" unless @database
      end
    end
  end

  # A subclass of DBRC designed to handle .dbrc files in XML format.  The
  # public methods of this class are identical to DBRC.
  class DBRC::XML < DBRC
    require 'rexml/document' # Good enough for small files
    include REXML

    private

    def parse_dbrc_config_file(file = @dbrc_file)
      doc = Document.new(File.new(file))
      fields = %w[user password driver interval timeout maximum_reconnects]
      doc.elements.each('/dbrc/database') do |element|
        next unless element.attributes['name'] == database
        next if @user && @user != element.elements['user'].text

        fields.each do |field|
          val = element.elements[field]
          send("#{field}=", val.text) unless val.nil?
        end

        break
      end

      raise Error, "No record found for #{@user}@#{@database}" unless @user && @database
    end
  end

  # A subclass of DBRC designed to handle .dbrc files in YAML format. The
  # public methods of this class are identical to DBRC.
  class DBRC::YML < DBRC
    require 'yaml'

    private

    def parse_dbrc_config_file(file = @dbrc_file)
      config = YAML.safe_load(File.open(file))

      config.each do |hash|
        hash.each do |db, info|
          next unless db == @database
          next if @user && @user != info['user']
          @user = info['user']
          @password = info['password']
          @driver = info['driver']
          @interval = info['interval']
          @timeout = info['timeout']
          @maximum_reconnects = info['maximum_reconnects']
          break
        end
      end

      raise Error, "No entry found for #{@user}@#{@database}" unless @user && @database
    end
  end
end
