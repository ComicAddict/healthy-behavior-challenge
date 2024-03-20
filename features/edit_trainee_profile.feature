Feature: Login
  As a user,
  I want to check my profile
  And edit my profile

Scenario: go to edit my profile
    Given I am logged in
    And I click on "My Profile"
    Then I should see 'My Profile'
    And I click on "Edit Profile"
    Then I should be on edit profile path
    Then I should see 'Edit Trainee Profile'


Scenario: edit my profile
    Given I am logged in
    And I click on "My Profile"
    Then I should see 'My Profile'
    And I click on "Edit Profile"
    Then I should be on edit profile path
    Then I should see 'Edit Trainee Profile'
    When I fill in 'Full name' with 'New Trainee'
    When I fill in 'height_feet' with '5'
    When I fill in 'height_inches' with '4'
    When I fill in 'Weight' with '100'
    And I click on "Update Profile"
    Then I should see 'Profile updated successfully'
    Then I should see 'New Trainee'
    Then I should see '100'

Scenario: cancel
    Given I am logged in
    And I click on "My Profile"
    Then I should see 'My Profile'
    And I click on "Edit Profile"
    Then I should be on edit profile path
    And I click on "Cancel"
    Then I should be on trainee profile path



    