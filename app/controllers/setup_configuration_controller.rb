class SetupConfigurationController < ApplicationController
  layout 'standard'
  before_filter :load_configuration, :only =>[:show, :edit,:update]

  def show
  end
  def edit
  end
  def update
    params[:configuration] ||= {:use_auto_video => false}
    @configuration.update_attributes(params[:configuration])
    render :action => "show"
  end

  private
  def load_configuration
    @configuration = SetupConfiguration.first
  end
end
