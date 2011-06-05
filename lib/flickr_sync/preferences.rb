require 'yaml'

module FlickrSync
  class Preferences
    def initialize
      @preference_path = home_path '.flickr_sync'
      if File.exists? @preference_path
        @preferences = YAML.load File.read(@preference_path)
      else
        @preferences = {}
      end
    end

    def [] key
      @preferences[key]
    end

    def []= key, value
      @preferences[key] = value
      persist
    end
private
    def home_path *paths
      File.join File.expand_path('~'), *paths
    end

    def persist
      File.open(@preference_path, 'w') {|f| f.puts @preferences.to_yaml}
    end
  end
end