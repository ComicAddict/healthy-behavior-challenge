Feature: Login
  As a user,
  I want to check my profile

Scenario: check my profile
    Given I am logged in
    And I click on "My Profile"
    Then I should see 'My Profile'

Scenario: check my profile
    Given I am on the trainee profile
    Then I should be on root path

Scenario: go to edit page my profile
    Given I am logged in
    And I click on "My Profile"
    Then I should see 'My Profile'
    And I click on "Edit Profile"
    Then I should be on edit profile path 