require 'flickraw'

module FlickrSync
  class Authentication
    attr_reader :preferences
    attr_reader :prompt

    def initialize prompt, preferences
      @prompt, @preferences = prompt, preferences
    end

    def start
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
    end

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
  end
end