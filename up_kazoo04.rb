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
    picture = ["It's dynamic kazoo04. http://t.co/jBGzCuKzhZ", "It's beautiful kazoo04. http://t.co/NlL7jRdqjC", "It's moonlight kazoo04. http://t.co/rw7AqkT3kz", "It's old kazoo04. http://t.co/RkCwaPKsSn", "It's transpicuous kazoo04. http://t.co/WH522CHrtT", "It's google kazoo04. http://t.co/Ok7D4JB3tQ", "It's google kazoo04. http://t.co/PA5FN97dp5", "It's cool kazoo04. http://t.co/JAp0RLIFbB", "It's writing kazoo04. http://t.co/MpE9sozJ5j", "It's lightning kazoo04 & grapswiz. http://t.co/TcdUigS3C0"]
    begin
        if status.text.match(/^@#{@screen_name}[\s　]*up_kazdesign[\s　]*(.+)/) #@sn update_name名前がマッチしてるか調べる
            number = $1 #抽出
            else #それでもない場合
            return #戻す
        end
    rescue => e #例外をeと定義
        p status, status.text
        p e #例外をターミナルに書き出す
    else 
        @rest_client.update("@#{status.user.screen_name} #{picture[number]}", :in_reply_to_status_id => status.id) #textで定義された物を呟く
    end
end

@stream_client.user do |object|
    next unless object.is_a? Twitter::Tweet
    
    unless object.text.start_with? "RT"
        up_kazoo04(object)
    end
end
