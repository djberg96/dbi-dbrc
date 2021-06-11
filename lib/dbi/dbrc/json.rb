# frozen_string_literal: true

require_relative '../dbrc'

# The DBI module serves as namespace only.
module DBI
  # A subclass of DBRC designed to handle .dbrc files in JSON format. The
  # public methods of this class are identical to DBRC.
  class DBRC::JSON < DBRC
    require 'json'

    private

    def parse_dbrc_config_file(file = @dbrc_file)
      begin
        fh = file.is_a?(StringIO) ? file : File.open(file)
        config = ::JSON.parse(fh.read)

        config.each do |db, info|
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
      ensure
        fh.close if fh && fh.respond_to?(:close)
      end

      raise Error, "No entry found for #{@user}@#{@database}" unless @user && @database
    end
  end
end
