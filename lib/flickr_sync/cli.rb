require 'clamp'
require 'fleakr'
require 'pathname'
require 'splat'

module FlickrSync
  class Cli < Clamp::Command
    option "--optimistic", :flag, "assume there are no duplicates"
    parameter "DIRECTORY_PATH", "the folder containing images"

    def execute
      preferences = FlickrSync::Preferences.new
      prompt = FlickrSync::Prompt.new STDIN, STDOUT

      preferences[:api_key] ||= prompt.answer 'What is your Flickr API key'
      preferences[:shared_secret] ||= prompt.answer 'What is your Flickr Shared Secret'
      preferences[:auth_token] ||= prompt.answer 'What is your Flickr Auth'
      preferences[:username] ||= prompt.answer 'What is your Flickr username'      

      Fleakr.api_key = preferences[:api_key]
      Fleakr.shared_secret =  preferences[:shared_secret]
      Fleakr.auth_token = preferences[:auth_token]
      user = Fleakr.user preferences[:username]

      written_path = File.join directory_path, 'written.txt'
      duplicates_path = File.join directory_path, 'duplicates.txt'

      allfiles = `find #{directory_path}/*`.split("\n").select {|p| ['.jpg', '.gif'].include? File.extname(p).downcase}
      puts "Found #{allfiles.count} image files"
      writtenfiles = load_list written_path
      puts "Found #{writtenfiles.count} previously sent files"
      newfiles = allfiles - writtenfiles
      puts "Found #{newfiles.count} files to send"

      newfiles.each_with_index do |file, index|
        path = Pathname.new file
        puts "#{path} (#{index+1}/#{newfiles.count})"
        unless optimistic?
          results = Fleakr.search :user_id => user.id, :text => path.basename.to_s.split('.').first
          skip_upload = false
          unless results.empty?
            ids = results.map {|r| r.id }.join ','
            puts "Found #{results.size} results on flickr: #{ids}"
            results.each {|r| r.small.url.to_launcher }
            file.to_launcher
            if prompt.ask('Had the photo already been uploaded', true)
              skip_upload = true
              if results.size > 1
                File.open(duplicates_path, 'a') {|f| f.puts "#{file},#{ids}"} if prompt.ask('Are these all duplicates', true)
              end
            end
          end
        end
        if skip_upload
          puts "skipping upload"
        else
          puts "uploading photo"
          Fleakr.upload file, :viewable_by => :family, :hide? => true
        end
        File.open(written_path, 'a') {|f| f.puts file }
      end
    end
private
    def load_list path
      return [] unless File.exist? path
      lines = []
      File.open path do |file|
        while line = file.gets
          lines << line.chomp
        end
      end 
      lines
    end
  end
end