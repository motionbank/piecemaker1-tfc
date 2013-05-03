class SyncController < ApplicationController
  require 'json'
  def run_sync
  uri = URI.parse('http://piecemaker.org/sync/catch_sync')
  c = Command.first.event_data
  post_params = {
    :command => c
  }

  # Convert the parameters into JSON and set the content type as application/json
  req = Net::HTTP::Get.new(uri.path)
  req.body = JSON.generate(post_params)
  req["Content-Type"] = "application/json"

  http = Net::HTTP.new(uri.host, uri.port)
  @response = http.start {|htt| htt.request(req)}
  end
  def catch_sync
    obj = JSON.load(params[:command].to_s)
    render :layout => false
  end
end
