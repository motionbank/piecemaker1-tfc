class SyncController < ApplicationController
  require 'json'
  def run_sync
  uri = URI.parse('http://piecemaker.org/sync/catch_sync')

  post_params = {
    :title => "2BR Apartment For Rent in NYC",
    :description => "Great midtown west location. I love this place.",
    :price => "1500",
    :api_key => "my_api_key"
  }

  # Convert the parameters into JSON and set the content type as application/json
  req = Net::HTTP::Get.new(uri.path)
  req.body = JSON.generate(post_params)
  req["Content-Type"] = "application/json"

  http = Net::HTTP.new(uri.host, uri.port)
  @response = http.start {|htt| htt.request(req)}
  end
  def catch_sync

  end
end
