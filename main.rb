#依存
require 'json'
require 'net/https'
require 'twitter'
require 'open-uri'

#auth認証情報の読み込み
require './param'

def archive_item(id)
    headers = {
        'Content-Type' =>'application/json; charset=UTF-8',
        'X-Accept' => 'application/json'
      }      
    params = {:consumer_key => $CONSUMER_KEY, :access_token => $POCKET_ACCESS_TOKEN, :actions => [{
        :action => $action_set, 
        :item_id => id.to_i
    }].to_json }
    data = params.map { |k, v| [k, v.to_s.encode('utf-8')] }.to_h

    http = Net::HTTP.new('getpocket.com', 443)
    http.use_ssl = true

    req = Net::HTTP::Post.new('/v3/send', initheader = headers)
    req.set_form_data(data)

    res = http.request(req)

    raise "error: cannot get response." unless res.is_a?(Net::HTTPOK)
    res_json = JSON.parse(res.body)

    puts "pocketで#{id}を#{$action_set}しました"
end


headers = {
  'Content-Type' =>'application/json; charset=UTF-8',
  'X-Accept' => 'application/json'
}

loop_flag = true
loop_counter = 0
since_id = ""
twitter_job_count = 0


while loop_flag do

    if loop_counter == 0 then

        params = {:consumer_key => $CONSUMER_KEY, :access_token => $POCKET_ACCESS_TOKEN, :sort => "newest", :count => 50}
        data = params.map { |k, v| [k, v.to_s.encode('utf-8')] }.to_h

        http = Net::HTTP.new('getpocket.com', 443)
        http.use_ssl = true

        req = Net::HTTP::Post.new('/v3/get', initheader = headers)
        req.set_form_data(data)

        res = http.request(req)

        raise "error: cannot get response." unless res.is_a?(Net::HTTPOK)
        twitter_job_count = 0
    else
        #2回目以降の取得処理
        if twitter_job_count == 0
            puts 'TwitterのURLはもうありません'
            break
        end

        params = {:consumer_key => $CONSUMER_KEY, :access_token => $POCKET_ACCESS_TOKEN, :sort => "newest", :count => 50, :since_id => since_id}
        data = params.map { |k, v| [k, v.to_s.encode('utf-8')] }.to_h

        http = Net::HTTP.new('getpocket.com', 443)
        http.use_ssl = true

        req = Net::HTTP::Post.new('/v3/get', initheader = headers)
        req.set_form_data(data)

        res = http.request(req)

        raise 'error: cannot get response.' unless res.is_a?(Net::HTTPOK)
        twitter_job_count = 0
    end

    res_json = JSON.parse(res.body)
    #ここからTwitterのURLだったらぶっこぬくよ
    if res_json['list'].size == 0
        loop_flag = false
        break
    else
        res_json['list'].each do |id, article|
            loop_counter += 1
            since_id = article['item_id']

            puts "#{loop_counter}回目 : #{article['excerpt']}"

            if article['given_url'] =~ /.*twitter.com.*/i then
                puts 'Twitterだと思う'
                puts  cut_url = article['given_url'].sub!(/.*\/status\//, '')
                begin
                    tweet_data = @client.status(cut_url)
                    
                    tweet_imgs = tweet_data.media.map{ |img| img.media_url.to_s }
                    tweet_imgs.each do |media_url|
                        path = "#{$save_dir}/#{File.basename(media_url)}"
                        File.open(path, 'wb') do |f|
                            f.write open(media_url).read
                        end
                    end
    
                    archive_item(article['item_id'])    #archiveするなり消すなりコロ助なり
    
                    puts '規制回避中'
                    sleep(1)
                    print "\n"
                    twitter_job_count += 1
                rescue => Twitter::Error
                    puts 'ツイートが消えてるか凍結かなにかで取得ませんでした'
                    before_set = $action_set
                    $action_set = 'delete'
                    archive_item(article['item_id'])
                    $action_set = before_set
                end
                

            else
                puts "Twitterじゃない"
                print "\n"
            end
        end
    end
end

puts '終わりました'