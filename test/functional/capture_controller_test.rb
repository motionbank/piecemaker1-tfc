require 'test_helper'
require 'capture_controller'

# Re-raise errors caught by the controller.
class CaptureController; def rescue_action(e) raise e end; end

class CaptureControllerTest < ActionController::TestCase
  def setup
    @controller = CaptureController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  
  def test_truth
    get :present
    assert_redirected_to :controller => 'home', :action => "welcome"
  end
  # logged_in_as "super_user" do
  #     should '' do
  #       get 'present',  :id => 1
  #       assert_response :success
  #       assert_equal current_user.login, "David"
  #     end
  # end
end
