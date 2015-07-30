require "./crybot/*"

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

    def stream
        @client.start_stream "GET", "/statuses/sample.json", do |body|
            p body
        end
    end
end

