# This controller handles the login/logout function of the site.  
class UsersessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  layout 'standard'
  include AuthenticatedSystem
  skip_before_filter :login_required , :only =>[:new, :create]
  # render new.rhtml
  def new
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    
    if user
        # Protects against session fixation attacks, causes request forgery
        # protection if user resubmits an earlier form using back
        # button. Uncomment if you understand the tradeoffs.
        # reset_session
        self.current_user = user
        new_cookie_flag = (params[:remember_me] == "1")
        handle_remember_cookie! new_cookie_flag
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
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:notice] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
