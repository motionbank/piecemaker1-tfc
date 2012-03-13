class SubSceneController < ApplicationController
  layout 'standard'
  def list
     redirect_non_admins('group_admin',home_url) and return
      @sub_scenes = SubScene.paginate(
                      :per_page => 50,
                      :page => params[:page],
                      :order => sort_from_universal_table_params,
                      :include => [{:event => :piece}])
  end
  
  def move_from_viewer
    @sub_scene = SubScene.find(params[:id])
    time = params[:time].gsub('.js','')
    @sub_scene.happened_at = @sub_scene.event.video.recorded_at + time.to_i
    @sub_scene.save
    #@sub_scene.check_for_reposition
    @video = @sub_scene.event.video
    respond_to do |format|
      format.html
      format.js {render :controller => 'events', :action => 'move_from_viewer'}
    end
  end
  def edit_sub_annotation
    @sub_scene = SubScene.find(params[:id])
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
end
