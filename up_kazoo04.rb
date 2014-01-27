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


def up_kazoo04(status)
    begin
        if status.text.match(/^@#{@screen_name}[\s　]*up_kazdesign[\s　]*(.+)/) #@sn update_name名前がマッチしてるか調べる
            number = $1 #抽出
            else #それでもない場合
            return #戻す
        end
        
        rescue => e #例外をeと定義
        p status, status.text
        p e #例外をターミナルに書き出す
        else #update_nameが成功した場合
        
        text = @orig_name == name ? "元に戻したよ！" : "I have just changed name “#{name}”!" #元の名前の場合は元に戻した、指定された場合はi have just...
        @rest_client.update("@#{status.user.screen_name} #{text}") #textで定義された物を呟く
    end
end

@stream_client.user do |object|
    next unless object.is_a? Twitter::Tweet
    
    unless object.text.start_with? "RT"
        update_name(object)
    end
end
