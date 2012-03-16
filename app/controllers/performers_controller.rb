class PerformersController < ApplicationController
  layout 'standard'
  def index
    @performers = Performer.order(sort_from_universal_table_params)
  end
  def new
    @performer = Performer.new
    respond_to do |wants|
      wants.html {  }
      wants.js { render :action => 'new', :layout => false}
    end
  end
  def create
    params[:performer][:user_id] = nil if params[:performer][:user_id] == 'None'
    params[:performer][:is_current] ||= false
    @performer = Performer.create(params[:performer])
    @performer.save
    redirect_to :action => 'index'
  end
  def edit
    @performer = Performer.find(params[:id])
  end
  def update
    params[:performer][:user_id] = nil if params[:performer][:user_id] == 'None'
    params[:performer][:is_current] ||= false
    @performer = Performer.find(params[:id])
    @performer.update_attributes(params[:performer])
    redirect_to :action => 'index'

  end
  def show
    @performer = Performer.find(params[:id])
  end
  def destroy
    Performer.find(params[:id]).destroy
    redirect_to :action => 'index', :id => current_configuration.id
  end
  def create_performers_from_users
    perfs = Performer.all
    perfs.each do |perf|
      us = User.find_by_login(perf.short_name)
      perf.user_id = us.id
      perf.save
    end
  end
end
