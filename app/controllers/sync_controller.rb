class SyncController < ApplicationController

  layout 'standard'
  def index
    @commands = Command.all
  end
  def clear_all
    Command.all.each{|x| x.destroy}
    redirect_to :action => 'index'
  end
  def error_string
    'big error'
  end

  def run_sync
    uri = URI.parse('http://piecemaker.org/sync/catch_sync')
    c = Command.all.map{|x| x.event_data}
    if c.any?
      post_params = {
        :command => c
      }

      # Convert the parameters into JSON and set the content type as application/json
      req = Net::HTTP::Get.new(uri.path)
      req.body = post_params.to_json
      req["Content-Type"] = "application/json"

      http = Net::HTTP.new(uri.host, uri.port)

      @response = http.start {|htt| htt.request(req)}
      if @response != error_string
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
    begin
      if params[:command]
        params[:command].each do |com|
          if com.first == 'destroy'
            if event = Event.find_by_id(com[1].to_i)
              @destroyed << event.title
              event.destroy
            end
          else
            if event = Event.find_by_id(com[:id].to_i)
              event.attributes = com
              event.save
            else
              event = Event.create_with_id(com)
            end
            @events << event
          end
          @commands << com
        end
      end
      render :layout => false
    rescue
      render :text => error_string
    end
  end

end
