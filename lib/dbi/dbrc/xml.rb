# frozen_string_literal: true

# The DBI module serves as a namespace only.
module DBI
  # A subclass of DBRC designed to handle .dbrc files in XML format.  The
  # public methods of this class are identical to DBRC.
  class DBRC::XML < DBRC
    require 'rexml/document' # Good enough for small files

    private

    def parse_dbrc_config_file(file = @dbrc_file)
      file = File.new(file) unless file.is_a?(StringIO)
      doc = REXML::Document.new(file)

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
end
