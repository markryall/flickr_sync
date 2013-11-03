require 'clamp'
require 'flickr_sync/preferences'
require 'flickr_sync/prompt'
require 'flickr_sync/authentication'
require 'flickr_sync/file_list'

module FlickrSync
  class Sync < Clamp::Command
    IMAGES_ONLY = %w{.jpg .gif .m4v}
    IMAGES_AND_VIDEO = IMAGES_ONLY + %w{.mp4 .mov}

    option "--video", :flag, "include videos"
    option "--dump", :flag, "don't upload anything - just dump the filenames"
    parameter "DIRECTORY_PATH", "the folder containing images"

    def prompt
      return @prompt if @prompt
      @prompt = FlickrSync::Prompt.new STDIN, STDOUT
    end

    def execute
      FlickrSync::Authentication.new(prompt, FlickrSync::Preferences.new).start

      written = FileList.new directory_path, 'written.txt'
      duplicates = FileList.new directory_path, 'duplicates.txt'

      file_extensions = video? ? IMAGES_AND_VIDEO : IMAGES_ONLY

      allfiles = `find "#{directory_path}"`.split("\n").select {|p| file_extensions.include? File.extname(p).downcase}
      $stderr.puts "Found #{allfiles.count} #{video? ? 'image/video' : 'image'} files"
      writtenfiles = written.all
      $stderr.puts "Found #{writtenfiles.count} previously sent files"
      newfiles = allfiles - writtenfiles
      $stderr.puts "Found #{newfiles.count} files to send"

      newfiles.each_with_index do |file, index|
        if dump?
          puts file
        else
          puts "> #{file} (#{newfiles.count - index} remaining)"
          flickr.upload_photo file, is_public: 0, is_family: 1, hidden: 2
        end
        written.append file
      end
    end
  end
end