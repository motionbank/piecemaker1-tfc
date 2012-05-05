# This controller handles the login/logout function of the site.  
class UsersessionsController < ApplicationController
  layout 'standard'
  skip_before_filter :login_required , :only =>[:new, :create]
  # render new.rhtml
  def new
  end

  def create
    #logout_keeping_session!
    user = User.find_by_login(params[:login])
    
    
    if @current_account && user && user.authenticate(params[:password])
        # self.current_user = user
        #         new_cookie_flag = (params[:remember_me] == "1")
        #         handle_remember_cookie! new_cookie_flag
        
        if params[:remember_me]
          cookies.permanent[:remember_token] = user.remember_token
        else
          cookies[:remember_token] = user.remember_token  
        end
        redirect_to home_url
        #redirect_back_or_default('/')
        flash[:notice] = "Logged in successfully!"
        user.last_login = Time.now
        user.save
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      redirect_to home_url
    end
  end

  def destroy
    #create_logout
    cookies.delete(:remember_token)
    redirect_to root_url, notice: "Logged out!"
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:notice] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
