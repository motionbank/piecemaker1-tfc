Feature: Getting to the Home Page
  In order to get into the system
  As a user 
  I want to be able to see the home page and log in and out

  Scenario: Going to the home page
    Given I am on "home"
    #When I go to the home page
    Then I should see "Welcome to Piecemaker"

  Scenario: I log in
    Given I am a new, authenticated user
    Then I should see "Logout"
    
  Scenario: I log out
    Given I am a new, authenticated user
    And I Logout
    Then I should see "Logged out!"
    