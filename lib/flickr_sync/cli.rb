require 'clamp'
require 'flickraw'
require 'pathname'
require 'splat'

module FlickrSync
  class Cli < Clamp::Command
    attr_reader :preferences
    attr_reader :prompt

    # option "--optimistic", :flag, "assume there are no duplicates"
    parameter "DIRECTORY_PATH", "the folder containing images"

    def api_key
      preferences[:api_key] ||= prompt.answer 'What is your Flickr API key'
    end

    def shared_secret
      preferences[:shared_secret] ||= prompt.answer 'What is your Flickr Shared Secret'
    end

    def has_authenticated?
      preferences[:access_token]
    end

    def store_authentication token
      preferences[:username] = token['username']
      preferences[:access_token] = token['oauth_token']
      preferences[:access_secret] = token['oauth_token_secret']
    end

    def access_token
      preferences[:access_token]
    end

    def access_secret
      preferences[:access_secret]
    end

    def execute
      @preferences = FlickrSync::Preferences.new
      @prompt = FlickrSync::Prompt.new STDIN, STDOUT

      FlickRaw.api_key = api_key
      FlickRaw.shared_secret = shared_secret

      unless has_authenticated?
        token = flickr.get_request_token
        auth_url = flickr.get_authorize_url(token['oauth_token'], :perms => 'delete')
        auth_url.to_launcher
        verify = prompt.answer 'What was the number'
        store_authentication flickr.get_access_token token['oauth_token'], token['oauth_token_secret'], verify
      end

      flickr.access_token = access_token
      flickr.access_secret = access_secret

      flickr.test.login

      written_path = File.join directory_path, 'written.txt'
      duplicates_path = File.join directory_path, 'duplicates.txt'

      allfiles = `find "#{directory_path}"`.split("\n").select {|p| ['.jpg', '.gif', '.m4v'].include? File.extname(p).downcase}
      puts "Found #{allfiles.count} image files"
      writtenfiles = load_list written_path
      puts "Found #{writtenfiles.count} previously sent files"
      newfiles = allfiles - writtenfiles
      puts "Found #{newfiles.count} files to send"

      newfiles.each_with_index do |file, index|
        path = Pathname.new file
        puts "#{path} (#{index+1}/#{newfiles.count})"
        skip_upload = false
        # unless optimistic?
        #   results = Fleakr.search :user_id => user.id, :text => path.basename.to_s.split('.').first
        #   unless results.empty?
        #     ids = results.map {|r| r.id }.join ','
        #     puts "Found #{results.size} results on flickr: #{ids}"
        #     results.each {|r| r.small.url.to_launcher }
        #     file.to_launcher
        #     if prompt.ask('Had the photo already been uploaded', true)
        #       skip_upload = true
        #       if results.size > 1
        #         File.open(duplicates_path, 'a') {|f| f.puts "#{file},#{ids}"} if prompt.ask('Are these all duplicates', true)
        #       end
        #     end
        #   end
        # end
        if skip_upload
          puts 'skipping upload'
        else
          puts 'uploading photo'
          flickr.upload_photo file, is_public: 0, is_family: 1, hidden: 2
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