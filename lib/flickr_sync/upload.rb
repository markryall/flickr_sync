require 'clamp'
require 'flickr_sync/preferences'
require 'flickr_sync/prompt'
require 'flickr_sync/authentication'
require 'flickr_sync/file_list'

module FlickrSync
  class Upload < Clamp::Command
    parameter "FILE_PATH", "the file containing image paths to upload"

    def prompt
      return @prompt if @prompt
      @prompt = FlickrSync::Prompt.new STDIN, STDOUT
    end

    def execute
      FlickrSync::Authentication.new(prompt, FlickrSync::Preferences.new).start
      lines = File.readlines(file_path).map {|s| s.chomp.strip }.select {|s| !s.empty? and !s.start_with?('#')}

      loop do
        break if lines.empty?
        lines.shift.tap {|s| puts "> #{s}" }.tap {|s| upload s }
        File.open("#{file_path}.tmp", 'w') {|f| f.puts lines.join "\n" }
        `mv #{file_path}.tmp #{file_path}`
      end
      `rm #{file_path}`
    end

    def upload file
      return unless File.exist? file
      flickr.upload_photo file, is_public: 0, is_family: 1, hidden: 2
    end
  end
end