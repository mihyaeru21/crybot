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

        @signature   = OAuth::Signature.new(consumer_key, consumer_secret, access_token, access_secret)
        @rest_client = HTTP::Client.new(REST_HOST, ssl: true)
    end

    def request(method, path, body = nil) # TODO: repalace body to params hash
        request = make_request(method, REST_HOST, path, body)
        return JSON.parse(@rest_client.exec(request).body)
    end

    # naive implementation
    def start_stream(method, path)
        request = make_request(method, STREAM_HOST, path)
        io = make_socket(request)
        request.to_io(io)

        # read header
        headers = HTTP::Headers.new
        while line = io.gets
            break if line == "\r\n" || line == "\n"
            name, value = HTTP.parse_header(line)
            headers.add(name, value)
        end

        # read body
        while (chunk_size = io.gets.not_nil!.to_i(16)) > 0
            body = io.read(chunk_size)
            p body
            begin
                yield JSON.parse(body)
            rescue
                # FIXME: !!!
            end
            io.gets # Read \r\n
        end
    end

    private def make_request(method, host, path, body = nil)
        request = HTTP::Request.new(method, API_VERSION + path)
        request.headers["Host"]          = host
        request.headers["Content-type"]  = "application/x-www-form-urlencoded"
        request.headers["Authorization"] = @signature.authorization_header(request, true, Time.utc_now.to_i.to_s, SecureRandom.hex(32))
        return request
    end

    private def make_socket(request)
        socket = TCPSocket.new(request.headers["Host"], 443)
        socket.sync = false
        return OpenSSL::SSL::Socket.new(socket)
    end
end

