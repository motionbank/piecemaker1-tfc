# require 'test_helper'
# 
# class HomeTest < ActionController::IntegrationTest
#   # Replace this with your real tests.
#   fixtures :users
#   should 'go to home page' do
#     visit '/'
#     assert_contain 'Welcome to '
#   end
#   # def test_david_can_login_and_out_from_home_page
#   #   visit '/'
#   #   assert_response :success
#   #   fill_in 'login', :with => 'David'
#   #   fill_in 'password', :with => 'swordfish'
#   #   click_button 'Login'
#   #   assert_response :success
#   #   assert_equal flash[:notice], 'Logged in successfully!'
#   #   click_link 'Logout'
#   #   assert_response :success
#   #   assert_equal flash[:notice], 'You have been logged out.'
#   # end
#   context 'logged in' do
#      setup do
#        #post("usersessions/create", :login => 'David', :password => 'swordfish')
#      end
#      
#      should 'have username set' do
#        #assert_equal current_user.login, 'David'
#        #assert_equal current_user.role_name, 'group_admin'
#        #assert user_has_right?('group_admin')
#      end
#    end
#  
# end
