class AccountController < ApplicationController
  layout 'standard'
  def show
    
  end
  def edit
    @account = @current_account
  end
  def update
    @account = @current_account
    @account.update_attributes(params[:account])
    redirect_to :action => 'show'
  end
end
