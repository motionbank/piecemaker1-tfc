class AdministrationController < ApplicationController
   layout 'standard'
   before_filter :redirect_if_not_admin, :except => :role_matrix
   def index
   end

  def delete_ev
    event = Event.find(params[:id])
    flash[:notice] = event.destroy ? "Destroyed Event ID: #{params[:id]}" : "Couldn't destroy Event ID: #{params[:id]}"
    redirect_to :controller => 'events',:action => 'list'
  end
  def delete_vid
    vid = Video.find(params[:id])
    flash[:notice] = vid.destroy ? "Destroyed Video ID: #{params[:id]}" : "Couldn't destroy Video ID: #{params[:id]}"
    redirect_to :controller => 'video', :action => 'list'
  end
  def delete_vid_rec
    vid_rec = VideoRecording.find(params[:id])
    flash[:notice] = vid_rec.destroy ? "Destroyed Video Recording ID: #{params[:id]}" : "Couldn't destroy Video Recording ID: #{params[:id]}"
    redirect_to :controller => 'video', :action => 'list_video_recordings'
  end
  
   def delete_s3
     @key = params[:id]
   end
   def list_s3
     @list = S3Config.connect_and_get_objects(current_configuration.s3_sub_folder)
   end
  
  def main
    @ur = request.host
    @env = SetupConfiguration.app_is_local? ? 'local' : 'heroku'
    @ip = request.remote_ip
  end

  def role_matrix
  end

  def list_logins
  end
  
  
  protected
  def redirect_if_not_admin
    unless user_has_right?('group_admin')
      redirect_to :controller => 'home', :action => 'welcome'
    end
  end
end
