class SyncController < ApplicationController
  require 'json'

  layout 'standard'

  def run_sync
    uri = URI.parse('http://piecemaker.org/sync/catch_sync')
    c = Command.all.map{|x| x.event_data}
    if c.any?
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
      if @response != 'big error'
        Command.all.each {|x| x.destroy}
      end
    else
      @response = 'nothing to do'
    end
  end

  def catch_sync
    @events = []
    @commands = []
    @destroyed = []
    # @obj = params[:command][:ivars][:attributes]
    if params[:command]
      params[:command].each do |com|
        if com == 'destroy'
          if event = Event.find_by_id(com[:id].to_i)
            @destroyed << event
            event.destroy
          end
        else
          if event = Event.find_by_id(com[:id].to_i)
            event.attributes = com
            event.save
          else
            event = Event.create_with_id(com)
          end
        end

        @commands << com
        @events << event
      end
    end
    render :layout => false
  end

end
