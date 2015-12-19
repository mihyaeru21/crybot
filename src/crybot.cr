require "./crybot/*"
require "uri"

class Crybot
    def initialize
        @client = Client.new
    end

    def get_tweets
        @client.request("GET", "/statuses/home_timeline.json")
    end

    def tweet(text)
        @client.request("POST", "/statuses/update.json", "status=#{text}")
    end

    def user_stream
        @client.start_stream "GET", "/user.json", do |body|
            p body
            if text = body["text"]?
                puts "text: #{text}"

                # ツイート返すぞ！！！
                if body["in_reply_to_user_id_str"]? == "3301456596"  # @crybot21
                    if user = body["user"]? as Hash
                        name = user["screen_name"]?
                        text = (text as String).gsub("@crybot21 ", "")
                        tweet_test = "@#{name} #{text}"
                        p self.tweet(URI.escape(tweet_test))
                        p tweet_test
                    end
                end
            end
        end
    end
end

