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


def kaztweets(status)
    begin
        if status.text.match(/^(.*@#{@screen_name}[\s　]*.*)/) #@sn update_name名前がマッチしてるか調べる
            tweet = $1 #抽出
        elsif status.text.match(/^(.*くろてい.*)/) #名前(@sn)をマッチしているか調べる
            tweet = $1
        else #それでもない場合
            return #戻す
        end   
    rescue => e #例外をeと定義
        p status, status.text
        p e #例外をターミナルに書き出す
    else #update_nameが成功した場合
        p tweet
        file_name = "kazmentions.txt"    #保存するファイル名

        File.open(file_name, 'a') {|file|
        file.write ("#{tweet}\n")
        }
    end
end

@stream_client.user do |object|
    next unless object.is_a? Twitter::Tweet
    
    unless object.text.start_with? "RT"
        kaztweets(object)
    end
end
