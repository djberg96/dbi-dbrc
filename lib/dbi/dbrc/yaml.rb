# frozen_string_literal: true

# The DBI module serves as namespace only.
module DBI
  # A subclass of DBRC designed to handle .dbrc files in YAML format. The
  # public methods of this class are identical to DBRC.
  class DBRC::YML < DBRC
    require 'yaml'

    private

    def parse_dbrc_config_file(file = @dbrc_file)
      fh = file.is_a?(StringIO) ? file : File.open(file)
      config = ::YAML.safe_load(fh)

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

DBI::DBRC::YAML = DBI::DBRC::YML # Alias
