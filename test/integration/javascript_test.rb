require 'test_helper'

class JavascriptTest < ActionController::IntegrationTest
  # Download jsl from http://www.javascriptlint.com and add the jsl to your PATH environment variable
  def setup
    @js_paths = File.join(Rails.root, 'public', 'javascripts', '*.js')
  end

  # test "validate javascript files for errors" do
  #     Dir[@js_paths].reject{|x| x.include?('_packaged')}.each do |js_path|
  #       output = %x[jsl -process #{js_path}]
  #     
  #       is_valid_js_file = output.include?("0 error(s)") ?  true : false
  #       assert(is_valid_js_file, "JSLint on #{js_path} should return no errors: \n #{output}")
  #     end
  #   end
end