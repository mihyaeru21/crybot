require "./crybot/*"

class Crybot
    def initialize
        @client = Client.new
    end

    def tweet(text)
        @client.request("POST", "/statuses/update.json", "status=#{text}")
    end
end

