require 'test_helper'
require 'meta_infos_controller'

# Re-raise errors caught by the controller.
class MetaInfosController; def rescue_action(e) raise e end; end

class MetaInfosControllerTest < ActionController::TestCase

  def setup
    @controller = MetaInfosController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
