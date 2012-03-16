class MessageController < ApplicationController
  layout 'standard'
  def index
    @messages = Message.where("user_id = ?",params[:id])
  end
  def list_all
    @messages = Message.all
    render :action => 'index'
  end
  def destroy
    Message.find(params[:id]).destroy
    redirect_to :action => 'index', :id => current_user.id
  end
end
