require "env"
require "json"
require "oauth"
require "time"
require "secure_random"

class Client
    HOST        = "api.twitter.com"
    API_VERSION = "/1.1"

    def initialize
        consumer_key    = ENV["CRYBOT_CONSUMER_KEY"]
        consumer_secret = ENV["CRYBOT_CONSUMER_SECRET"]
        access_token    = ENV["CRYBOT_ACCESS_TOKEN"]
        access_secret   = ENV["CRYBOT_ACCESS_SECRET"]

        @signature = OAuth::Signature.new(consumer_key, consumer_secret, access_token, access_secret)
        @client    = HTTP::Client.new(HOST, ssl: true)
    end

    def request(method, path, body = nil) # TODO: repalace body to params hash
        request = HTTP::Request.new(method, API_VERSION + path, body: body)
        request.headers["Host"]          = HOST
        request.headers["Content-type"]  = "application/x-www-form-urlencoded"
        request.headers["Authorization"] = @signature.authorization_header(request, true, Time.now.to_i.to_s, SecureRandom.hex)
        return JSON.parse(@client.exec(request).body)
    end
end

