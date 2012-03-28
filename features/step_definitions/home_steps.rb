When /^I go to the home page$/ do
  visit '/'
end

Given /^I am on "([^"]*)"$/ do |path|
  visit path
end

Then /^I should see "([^"]*)"$/ do |text|
  page.should have_content text
end

Given /^I am not logged in$/ do
  ! current_user
end

Given /^I am a new, authenticated user$/ do
  email = 'testing@man.net'
  password = 'secretpass'
  User.new(:login => email, :password => password, :password_confirmation => password).save!

  visit '/'
  fill_in "login", :with=>email
  fill_in "password", :with=>password
  click_button "Login"

end

Given /^I Logout$/ do
  click_link "Logout"
end