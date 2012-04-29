class AccountController < ApplicationController
  layout 'standard'
  def show
    
  end
  def edit
    @account = @current
  end
  def update
    @account = @current
    @account.update_attributes(params[:account])
    redirect_to :action => 'show'
  end
end
