class ConfigurationController < ApplicationController
  layout 'standard'
  before_filter :load_configuration, :only =>[:show, :edit, :edit_locations, :update_location,:update]

  def show
  end
  def edit
  end
  def update
    params[:configuration] ||= {:use_auto_video => false}
    @configuration.update_attributes(params[:configuration])
    render :action => "show"
  end
  def add_location
    location = Location.create(
    :location => params[:location])
    redirect_to :action => "show"
  end
  def edit_locations
  end
  def delete_location
    if current_configuration.location_id == params[:id].to_i
      flash[:notice] = "You can't delete your current location! Please change your location first."
      redirect_to :action => 'show'
    else
      location = Location.find(params[:id])
      location.destroy
      redirect_to :action => "show"
    end
  end
  def update_location
    loc = Location.find_by_location(params[:id])
    if loc
      @configuration.location_id = loc.id
      @configuration.save
      render :text => "alert('Location changed to #{@configuration.location.location}');$('#star').html('#{@configuration.location.location}')"
    else
      render :text => "alert('no change')"
    end
    
  end
  private
  def load_configuration
    @configuration = Configuration.first
  end
end
