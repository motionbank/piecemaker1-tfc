class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  #include AuthenticatedSystem
  layout "standard"
  before_filter :redirect_non_admins, :except => [:pref, :store_prefs]
  # render new.rhtml
  def new
    @user = User.new
  end
  
###################from pieces 
  def pref
    render :layout => false
  end
  def store_prefs
    set_time_zone
    current_user.store_from_params(params)
    flash[:notice] = 'New Preferences Stored'
    respond_to do |format|
      format.html {redirect_to :controller => 'capture',
        :action => "present",
        :id => session[:pieceid]}
      format.js {render :text => "clearFormDiv(); flashMessage('#{flash[:notice]}');", :layout => false} 
    end
  end
  
############################ 
  
  def create
      #logout_keeping_session!
      params[:performer] ||= false
      @user = User.new(params[:user])
      @user.role_name = params[:user][:role_name]
      success = @user && @user.save
      if success && @user.errors.empty?
        if params[:performer]
          p = Performer.create(
          :short_name => params[:performer_short_name],
          :first_name => params[:performer_first_name],
          :last_name => params[:performer_last_name],
          :user_id => @user.id)
        end
              # Protects against session fixation attacks, causes request forgery
        # protection if visitor resubmits an earlier form using back
        # button. Uncomment if you understand the tradeoffs.
        # reset session
        #self.current_user = @user # !! now logged in
        redirect_to :controller => :users, :action => :index
        flash[:notice] = "New User #{@user.login} has been added."
      else
        flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
        render :action => 'new'
      end
  end
  
  def edit_user
      @user = User.find(params[:id])
  end
  
  def destroy
      id = params[:id]
      if id && user = User.find(id)
        if User.all.length > 1 # prevents destruction of last user
          begin
            user.destroy
            flash[:notice] = "User #{user.login} deleted"
          rescue Exception => e
            flash[:notice] = e.message
          end
        else
          flash[:notice] = "You can't destroy the last user!"
        end
      end
      redirect_to(:action => :index)
  end

  def index
    sorter = params[:sorter] ? params[:sorter] : 'id'
    order = params[:order] ? params[:order] : 'DESC'
    @order = order == 'ASC' ? 'DESC' : 'ASC'
    sorts = {'id' => 'id', 'login' => 'login', 'role' => 'role_name'}
    @all_users = User.find(:all, :order => sorts[params[:sorter]],:include => [:performer] )
  end

  def update
      @user = User.find(params[:id])
      params[:performer] ||= false
      if @user.update_attributes(params[:user])
        if params[:performer]
          if @user.performer
            @user.performer.short_name = params[:performer_short_name]
            @user.performer.first_name = params[:performer_first_name]
            @user.performer.last_name = params[:performer_last_name]
            @user.performer.save
          else
            p = Performer.create(
              :short_name => params[:performer_short_name],
              :first_name => params[:performer_first_name],
              :last_name => params[:performer_last_name],
              :user_id => @user.id)
          end
        else
          if @user.performer
            @user.performer.destroy
          end
        end
        flash[:notice] = 'User was successfully updated.'
        redirect_to :action => 'index'
      else
        render :action => 'edit_user'
      end
  end

  
end
