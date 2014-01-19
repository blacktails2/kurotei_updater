# Coding: UTF-8
require 'twitter'
require './key.rb'

CONSUMER_KEY    = Conf::CONSUMER_KEY
CONSUMER_SECRET = Conf::CONSUMER_SECRET
ACCESS_TOKEN    = Conf::ACCESS_TOKEN
ACCESS_SECRET   = Conf::ACCESS_SECRET

@rest_client = Twitter::REST::Client.new do |config|
    config.consumer_key        = CONSUMER_KEY
    config.consumer_secret     = CONSUMER_SECRET
    config.access_token        = ACCESS_TOKEN
    config.access_token_secret = ACCESS_SECRET
end

@stream_client = Twitter::Streaming::Client.new do |config|
    config.consumer_key       = CONSUMER_KEY
    config.consumer_secret    = CONSUMER_SECRET
    config.oauth_token        = ACCESS_TOKEN
    config.oauth_token_secret = ACCESS_SECRET
end

@orig_name, @screen_name = [:name, :screen_name].map{|x| @rest_client.user.send(x) }


def update_name(status)
    begin
        if status.text.match(/^@#{@screen_name} *update_name( (.+))?/)
            name = $1
            elsif status.text.match(/^(.+?)[\s　]*[(（]@#{@screen_name}[)）]/)
            name = $1
            else
             return
        end

        if name && 20 < name.length
            text = "so long."
            raise "New name is too long"
        end
        text = @orig_name == name ? "元に戻したよ！" : "I just have changed name “#{name}”!"
        @rest_client.update("@#{status.user.screen_name} #{text}")
        @rest_client.update_profile(name: name)
    rescue => e
        p status, status.text
        p e
    end
end

@stream_client.user do |object|
    next unless object.is_a? Twitter::Tweet
    
    unless object.text.start_with? "RT"
        update_name(object)
    end
end
