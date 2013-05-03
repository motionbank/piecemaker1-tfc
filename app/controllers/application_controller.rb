class ApplicationController < ActionController::Base
  protect_from_forgery

    # Pick a unique cookie name to distinguish our session data from others'
    #session :session_key => '_piecemaker_session_id'

    before_filter :login_required, :except => [:login, :welcome, :documentation, :contact,:update_vid_time,:mark_from_marker_list,:catch_sync]

    before_filter :set_defaults, :except => [:authorize,:update_vid_time,:fill_video_menu,:fill_extra_menu,:quick_marker,:mark_from_marker_list]
    before_filter :catch_came_from

    helper_method :user_has_right?, :duration_to_hash, :duration_hash_to_string, :video_in?
    helper_method :yield_authenticity_token, :current_piece, :s3_bucket, :came_from_or,:set_time_zone
##################
  # def current_user
  #   @cu ||= User.find(1)
  # end


  def logged_in?
    !!current_user
  end

  def authorized?(action=nil, resource=nil, *args)
    logged_in?
  end

  def login_required
    authorized? || access_denied
  end


  # Redirect as appropriate when an access request fails.
  #
  # The default action is to redirect to the login screen.
  #
  # Override this method in your controllers if you want to have special
  # behavior in case the user is not authorized
  # to access the requested action.  For example, a popup window might
  # simply close itself.
  def access_denied
    respond_to do |format|
      format.html do
        redirect_to new_usersession_path
      end
      # format.any doesn't work in rails version < http://dev.rubyonrails.org/changeset/8987
      # you may want to change format.any to e.g. format.any(:js, :xml)
      format.any do
        request_http_basic_authentication 'Web Password'
      end
    end
  end



  helper_method :current_user,:login_required,:authorized?,:logged_in?
#################


    def catch_came_from
      @came_from ||= url_for(:controller => params[:controller],:action => params[:action], :id => params[:id],:only_path => true)
    end

    def came_from_or(a_path=nil)
      params[:came_from] || a_path
    end

    def redirect_non_admins(right = 'group_admin',destination = pieces_url)
      unless user_has_right?(right)
        flash[:notice] = "You can't do that!"
        redirect_to destination
      end
    end
    def s3_bucket
      @bucket ||= S3Config.bucket
    end

    def yield_authenticity_token
        if protect_against_forgery?
            "<script type='text/javascript'>
            //<![CDATA[
              window._auth_token_name = '#{request_forgery_protection_token}';
              window._auth_token = '#{form_authenticity_token}';
            //]]>
          </script>"
        end
      end

    def set_time_zone
      SetupConfiguration.time_zone
    end

    def user_has_right?(right)
      return false unless current_user
      result = SetupConfiguration.rights[right].include? current_user.role_name
    end


    def set_current_piece(id)
      return false unless id
      @current_piece = Piece.find_by_id(id)
    end

    def current_piece
      @current_piece
    end

    def unset_current_piece
      @current_piece = nil
    end

    def set_defaults
      if(current_user)
        @refresh    = current_user.refresh_pref == 0 ? 'Never' : current_user.refresh_pref.to_s
        @truncate   = current_user.truncate.to_sym
        set_time_zone
        @pieces = Piece.all
      end
    end

    def video_in?
      current_video
    end

    def current_video
      videos = current_piece.videos
      return false unless videos.length > 0
      video = videos.last
      return video unless video.dur
      return video if (video.happened_at + video.dur) >= Time.now
      false
    end


    def params_to_duration(prefix = :duration)
      params[prefix][:hour].to_i*60*60 + params[prefix][:minute].to_i*60 + params[prefix][:second].to_i
    end
    def duration_to_hash(duration)
      duration_hash = Hash.new
      tempval =  duration.divmod(60 * 60)
      duration_hash[:hours]   = tempval[0]
      tempval2 = tempval[1].divmod(60)
      duration_hash[:minutes] = tempval2[0]
      duration_hash[:seconds] = tempval2[1]
      duration_hash
    end
    def duration_hash_to_string(duration)
      ((duration[:hours]<10) ? '0': '')+duration[:hours].to_s+'h'+((duration[:minutes]<10) ? '0': '')+duration[:minutes].to_s+'m'+ ((duration[:seconds]<10) ? '0': '')+duration[:seconds].to_s+'s'
    end

  protected
  def access_denied
    #store_location
    if flash[:notice]
      flash[:notice] += ' Please Login'
    else
      flash[:notice] = 'Please Login'
    end
    redirect_to :controller => 'home', :action => 'welcome'
  end

  private


    def current_user
      @current_user ||= User.find_by_remember_token( cookies[:remember_token]) if cookies[:remember_token]
    end
    helper_method :current_user
    # def authorize
    #       set_current_user
    #       unless @current_user
    #         flash[:notice] = "Please log in"
    #         redirect_to(:controller => "home", :action => "welcome")
    #       end
    #     end




end
