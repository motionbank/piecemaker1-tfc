require 'test_helper'
require 'pieces_controller'

# Re-raise errors caught by the controller.
class PiecesController; def rescue_action(e) raise e end; end

class PiecesControllerTest < ActionController::TestCase

  def setup
    @controller = PiecesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
