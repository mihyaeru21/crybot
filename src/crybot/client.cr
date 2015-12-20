require "env"
require "json"
require "oauth"
require "openssl"
require "secure_random"
require "socket"
require "time"
require "http"

class Client
    REST_HOST   = "api.twitter.com"
    STREAM_HOST = "userstream.twitter.com"  # FIXME: user_stream only!!!
    API_VERSION = "/1.1"

    def initialize
        consumer_key    = ENV["CRYBOT_CONSUMER_KEY"]
        consumer_secret = ENV["CRYBOT_CONSUMER_SECRET"]
        access_token    = ENV["CRYBOT_ACCESS_TOKEN"]
        access_secret   = ENV["CRYBOT_ACCESS_SECRET"]

        @signature     = OAuth::Signature.new(consumer_key, consumer_secret, access_token, access_secret)
        @rest_client   = HTTP::Client.new(REST_HOST, ssl: true)
        @stream_client = HTTP::Client.new(STREAM_HOST, ssl: true)
    end

    def request(method, path, body = nil) # TODO: repalace body to params hash
        request = make_request(method, REST_HOST, path, body)
        return JSON.parse(@rest_client.exec(request).body)
    end

    # naive implementation
    def start_stream(method, path)
        request = make_request(method, STREAM_HOST, path)
        @stream_client.exec(request) do |response|
            while true
                line = response.body_io.gets as String
                next if line =~ /^\s+$/
                yield JSON.parse(line) as Hash
            end
        end
    end

    private def make_request(method, host, path, body = nil)
        request = HTTP::Request.new(method, API_VERSION + path, body: body)
        request.headers["Host"]          = host
        request.headers["Content-type"]  = "application/x-www-form-urlencoded" if method == "POST"
        request.headers["Authorization"] = @signature.authorization_header(request, true, Time.utc_now.epoch.to_s, SecureRandom.hex(32))
        return request
    end
end

