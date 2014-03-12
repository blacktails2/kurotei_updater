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
        if status.text.match(/^@#{@screen_name}[\s　]*update_name[\s　]*(.+)/) #@sn update_name名前がマッチしてるか調べる
            name = $1 #抽出
        elsif status.text.match(/^@#{@screen_name}[\s　]*(俺|君|僕|私|儂|朕|某|麿|予|余|我|吾|妾|麻呂|自分|俺ら|おい|おいどん|ぼくちん|ミー|当方|吾輩|我輩|小生|吾人|愚生|非才|拙者|此方|俺様|くろてい|ブラテイ)(の名前)??は(.+)/) #名前(@sn)をマッチしているか調べる
            name = $3 #抽出
        elsif status.text.match(/^(.+?)[\s　]*[(（][\s　]*@#{@screen_name}[\s　]*[)）].*/) #名前(@sn)をマッチしているか調べる
            name = $1
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
        text = @orig_name == name ? "元に戻したよ！" : "I have just changed name “#{name}” by" #元の名前の場合は元に戻した、指定された場合はi have just...
        @rest_client.update("#{text} .@#{status.user.screen_name}！", :in_reply_to_status_id => status.id) #textで定義された物を呟く
    end
end

@stream_client.user do |object|
    next unless object.is_a? Twitter::Tweet
    
    unless object.text.start_with? "RT"
        update_name(object)
    end
end
