class MessageController < ApplicationController
  layout 'standard'
  def index
    @messages = Message.find_all_by_user_id(params[:id])
  end
  def list_all
    @messages = Message.find(:all)
    render :action => 'index'
  end
  def destroy
    Message.find(params[:id]).destroy
    redirect_to :action => 'index', :id => current_user.id
  end
end
