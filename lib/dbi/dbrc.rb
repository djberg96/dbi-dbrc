require 'rbconfig'

if Config::CONFIG['host_os'] =~ /mswin|win32|dos/i
   require 'win32/file'
   require 'win32/dir'
   require 'win32/process'
end

require 'sys/admin'

# The DBI module serves as a namespace only.
module DBI

   # The DBRC class encapsulates a database resource config file.
   class DBRC

      # This error is raised if anything fails trying to read the config file.
      class Error < StandardError; end

      # The version of the dbi-dbrc library
      VERSION = '1.1.6'

      @@windows = Config::CONFIG['host_os'] =~ /mswin|win32|dos/i

      # The database or host to be connected to.
      attr_accessor :database

      # The user name used for the database or host connection.
      attr_accessor :user

      # The password associated with the database or host.
      attr_accessor :password

      # The driver associated with the database. This is used to internally to
      # construct the DSN.
      attr_accessor :driver

      # Data source name, e.g. "dbi:OCI8:your_database".
      attr_accessor :dsn

      # The maximum number of reconnects a program should make before
      # giving up.
      attr_accessor :maximum_reconnects

      # The timeout, in seconds, for each connection attempt.
      attr_accessor :timeout

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
      # combination, then a Error is raised.  If the .dbrc file cannot
      # be found, or is setup improperly with regards to permissions or
      # properties, a DBI::DBRC::Error is raised.
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
      def initialize(database, user=nil, dbrc_dir=nil)
         if dbrc_dir.nil?
            uid  = Process.uid
            home = ENV['HOME'] || ENV['USERPROFILE']

            if home.nil?
               if @@windows
                  home ||= Sys::Admin.get_user(uid, :localaccount => true).dir
               else
                  home ||= Sys::Admin.get_user(uid).dir
               end
            end

            # Default to the app data directory on Windows if no home dir found
            if @@windows && home.nil?
               @dbrc_file = File.join(File.basename(Dir::APPDATA), '.dbrc')
            else
               uid = Process.uid
               @dbrc_file = File.join(Sys::Admin.get_user(uid).dir, '.dbrc')
            end
         else
            raise Error, 'bad directory' unless File.directory?(dbrc_dir)
            @dbrc_file = File.join(dbrc_dir, '.dbrc')
         end
         
         @dbrc_dir  = dbrc_dir
         @database  = database
         @user      = user
         encrypted  = false # Win32 only

         @driver   = nil
         @interval = nil
         @timeout  = nil
         @maximum_reconnects = nil

         check_file()
         
         # If on Win32 and the file is encrypted, decrypt it.
         if @@windows && File.encrypted?(@dbrc_file)
            encrypted = true
            File.decrypt(@dbrc_file)
         end
         
         parse_dbrc_config_file()
         validate_data()
         convert_numeric_strings()
         create_dsn_string()
         
         # If on Win32 and the file was encrypted, re-encrypt it
         if @@windows && encrypted
            File.encrypt(@dbrc_file)
         end
      end

      # Inspection of the DBI::DBRC object. This is identical to the standard
      # Ruby Object#inspect, except that the password field is filtered.
      #
      def inspect 
         str = instance_variables.map{ |iv| 
            if iv == '@password'
               "#{iv}=[FILTERED]"
            else
               "#{iv}=#{instance_variable_get(iv).inspect}" 
            end
         }.join(', ') 

         "#<#{self.class}:0x#{(self.object_id*2).to_s(16)} " << str << ">"
      end

      private

      # Ensure that the user/password has been set
      def validate_data
         unless @user
            raise Error, "no user found associated with #{@database}"
         end

         unless @password
            raise Error, "password not defined for #{@user}@#{@database}"
         end
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
      def check_file(file=@dbrc_file)
         File.open(file){ |f|

            # Permissions must be set to 600 or better on Unix systems.
            # Must be hidden on Win32 systems.
            if @@windows
               unless File.hidden?(file)
                  raise Error, "The .dbrc file must be hidden"
               end
            else
               unless (f.stat.mode & 077) == 0
                  raise Error, "Bad .dbrc file permissions"
               end
            end

            # Only the owner may use it
            unless f.stat.owned?
               raise Error, "Not owner of .dbrc file"
            end
         }
      end

      # Parse the text out of the .dbrc file.  This is the only method you
      # need to redefine if writing your own config handler.
      def parse_dbrc_config_file(file=@dbrc_file)
         IO.foreach(file){ |line|
            next if line =~ /^#/    # Ignore comments
            db, user, pwd, driver, timeout, max, interval = line.split

            next unless @database == db

            if @user
               next unless @user == user
            end

            @user               = user
            @password           = pwd
            @driver             = driver
            @timeout            = timeout
            @maximum_reconnects = max
            @interval           = interval
            return
         }

         # If we reach here it means the database and/or user wasn't found
         if @user
            err = "no record found for #{@user}@#{@database}"
         else
            err = "no record found for #{@database}"
         end

         raise Error, err
      end

      alias_method(:db, :database)
      alias_method(:db=, :database=)
      alias_method(:passwd, :password)
      alias_method(:passwd=, :password=)
      alias_method(:max_reconn, :maximum_reconnects)
      alias_method(:max_reconn=, :maximum_reconnects=)
      alias_method(:time_out, :timeout)
      alias_method(:time_out=, :timeout=)
      alias_method(:host, :database)
   end

   # A subclass of DBRC designed to handle .dbrc files in XML format.  The
   # public methods of this class are identical to DBRC.
   class XML < DBRC
      require "rexml/document"
      include REXML
      private
      def parse_dbrc_config_file(file=@dbrc_file)
         doc = Document.new(File.new(file))
         fields = %w/user password driver interval timeout maximum_reconnects/
         doc.elements.each("/dbrc/database"){ |element|
            next unless element.attributes["name"] == database
            if @user
               next unless element.elements["user"].text == @user
            end
            fields.each{ |field|
               val = element.elements[field]
               unless val.nil?
                  send("#{field}=",val.text)
               end
            }
            return
         }
         # If we reach here it means the database and/or user wasn't found
         raise Error, "No record found for #{@user}@#{@database}"
      end
   end

   # A subclass of DBRC designed to handle .dbrc files in YAML format. The
   # public methods of this class are identical to DBRC.
   class YML < DBRC
      require "yaml"
      private
      def parse_dbrc_config_file(file=@dbrc_file)
         config = YAML.load(File.open(file))
         config.each{ |hash|
            hash.each{ |db,info|
               next unless db == @database
               if @user
                  next unless @user == info["user"]
               end
               @user       = info["user"]            
               @password   = info["password"]
               @driver     = info["driver"]
               @interval   = info["interval"]
               @timeout    = info["timeout"]
               @maximum_reconnects = info["max_reconn"]
               return
            }
         }
         # If we reach this point, it means the database wasn't found
         raise Error, "No entry found for #{@user}@#{@database}"
      end
   end
end
