Feature: View Trainees Navigation
  As an instructor
  I want to click on the 'View Trainees' link
  So that I can see all my trainees

  Scenario: Instructor clicks on 'View Trainees' link
    Given I have instructor access
    Given I am on the homepage
    When I click on the 'View Trainees' link
    Then I should be on the 'View Trainees' page

  Scenario: Instructor views a trainee's profile details
    Given I have instructor access
    And I am on the "View Trainees" page with at least one trainee
    When I click on the "View Profile" button for the first trainee
    Then I should be on that trainee's profile details page
  
  Scenario: Instructor returns to the 'View Trainees' page from a trainee's profile
    Given I am on a trainee's profile details page
    When I click on the "Back to All Trainees" button
    Then I should be back on the "View Trainees" page

  Scenario: Instructor tries to view a non-existent trainee's profile
    Given I have instructor access
    And I am on the "View Trainees" page
    When I attempt to view a profile for a non-existent trainee
    Then I should see an error message indicating the trainee does not exist

  Scenario: No trainees are available to view
    Given I have instructor access
    And I am on the "View Trainees" page
    And no trainees exist
    Then I should see a message indicating there are no trainees to display

  Scenario: Instructor views a trainee's challenges
    Given I have instructor access
    And I am on the "View Trainees" page with at least one trainee
    When I click on the "Challenges" button for the first trainee
    Then I should be on that trainee's challenges page

  Scenario: Instructor views a trainee's challenge progress
    Given I have instructor access
    And I am on the "View Trainees" page with at least one trainee
    When I click on the "Challenges" button for the first trainee
    And I click on the "Progress" button for the first challenge
    Then I should be on that challenge's progress page for the trainee
  
  Scenario: Instructor views a trainee's challenges with no challenges available
    Given I have instructor access
    And I am on the "View Trainees" page with at least one trainee but no challenges
    When I click on the "Challenges" button for the first trainee
    Then I should see messages indicating there are no current or past challenges

  Scenario: Instructor navigates back from a trainee's progress view to the challenge page
    Given I have instructor access
    And I am on the "View Trainees" page with at least one trainee
    When I click on the "Challenges" button for the first trainee
    And I click on the "Progress" button for the first challenge
    And I click on the "Back" button
    Then I should be back on that trainee's challenges page

