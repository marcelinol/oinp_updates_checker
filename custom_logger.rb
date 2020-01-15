require 'json'
require 'net/http'

class CustomLogger
  def initialize(url_to_post = 'https://eni5fufeecmhj.x.pipedream.net/')
    @url =  url_to_post
  end

  def log(message)
    uri = URI(@url)
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')

    req.body = { "message": message }.to_json

    Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(req)
    end
  end
end
