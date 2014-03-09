# Coding: UTF-8
require 'twitter'
require 'yaml'
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

def ng_word?(name)
    ng_words = YAML.load_file("ng_word.yml")
    if ng_words.kind_of?(Array)
        ng_words.map do |ng_word|
            true if name.include?(ng_word)
        end.include?(true)
    else
        false
    end
end

def update_name(status)
    begin
        if status.text.match(/^(くろてい|ブラテイ|クロテイ|ぶらてい|ｸﾛﾃｲ|ﾌﾞﾗﾃｲ)(君|くん|クン|ｸﾝ|氏|さん)??は(.+)/) #名前(@sn)をマッチしているか調べる
            name = $3 #抽出
        else #それでもない場合
            return #戻す
        end
        
        if ng_word?(name) #ngワードを調べる
            @rest_client.update("@#{status.user.screen_name} NGワードが含まれています。変な名前にするな(戒め)", :in_reply_to_status_id => status.id) #戒めを呟く
            return
        end
        
    rescue => e #例外をeと定義
        p status, status.text
        p e #例外をターミナルに書き出す
    else #update_nameが成功した場合
        if name && 20 < name.length #名前が20文字を越えている場合
            text = "so long." #呟くtextを定義
            @rest_client.update("@#{status.user.screen_name} #{text}", :in_reply_to_status_id => status.id) #呟く
            puts "名前が長い" #ターミナルにエラーを書き出す
            return
        end
        @rest_client.retweet(status.id)
        @rest_client.update_profile(name: name) #名前を指定された物に変える
        text = @orig_name == name ? "元に戻したよ！" : "タイムラインから“#{name}”に変更しました！! by" #元の名前の場合は元に戻した、指定された場合はi have just...
        @rest_client.update("#{text} .@#{status.user.screen_name}", :in_reply_to_status_id => status.id) #textで定義された物を呟く
    end
end

@stream_client.user do |object|
    next unless object.is_a? Twitter::Tweet
    
    unless object.text.start_with? "RT"
        update_name(object)
    end
end
