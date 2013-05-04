class SyncController < ApplicationController
  require 'json'


  def run_sync
  uri = URI.parse('http://piecemaker.org/sync/catch_sync')
    c = Command.all.map{|x| x.event_data}
  #c = [Command.first.event_data]
    #c = Marshal.dump(c)
    post_params = {
      :command => c
    }

    # Convert the parameters into JSON and set the content type as application/json
    req = Net::HTTP::Get.new(uri.path)
    req.body = post_params.to_json
    req["Content-Type"] = "application/json"

    http = Net::HTTP.new(uri.host, uri.port)
    @response = http.start {|htt| htt.request(req)}
  end

  def catch_sync
    @events = []
    @commands = []
    # @obj = params[:command][:ivars][:attributes]
    params[:command].each do |com|

      if event = Event.find_by_id(com[:id].to_i)
        event.attributes = com
        event.save
      else
        event = Event.create_with_id(com[:ivars][:attributes])
      end

      @commands << com
      @events << event
    end
    render :layout => false
  end

end
