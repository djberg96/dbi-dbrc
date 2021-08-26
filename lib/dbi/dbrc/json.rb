# frozen_string_literal: true

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

        config.each do |hash|
          db = hash.keys.first
          next unless db == @database
          next if @user && @user != hash[db]['user']
          @user = hash[db]['user']
          @password = hash[db]['password']
          @driver = hash[db]['driver']
          @interval = hash[db]['interval']
          @timeout = hash[db]['timeout']
          @maximum_reconnects = hash[db]['maximum_reconnects']
          break
        end
      ensure
        fh.close if fh && fh.respond_to?(:close)
      end

      raise Error, "No entry found for #{@user}@#{@database}" unless @user && @database
    end
  end
end
