module FlickrSync
  class Prompt
    def initialize inio, outio
      @inio, @outio = inio, outio
    end

    def ask prompt, default
      default_answer = default ? 'y' : 'n'
      response = answer prompt, default_answer
      response = default_answer if response.empty?
      response.start_with? 'y'
    end

    def answer prompt, default=nil
      @outio.print default ? "#{prompt} [#{default}] ? " : "#{prompt} ? "
      @inio.gets.chomp.strip
    end
  end
end