module FlickrSync
  class FileList
    attr_reader :path

    def initialize *args
      @path = File.join *args
    end

    def all
      return [] unless File.exist? path
      lines = []
      File.open path do |file|
        while line = file.gets
          lines << line.chomp
        end
      end
      lines
    end

    def append file
      File.open(path, 'a') {|f| f.puts file }
    end
  end
end