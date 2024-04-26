Feature: Instructor Referral
  As an Instructor,
  I want to send a referral mail with a unique link
  So that new specified user can access the signup page

  Background:
    Given there is a instructor registered with the email "instructor@example.com" and password "abcdef"

  Scenario: Sending a referral email with a unique link
    Given I am logged in as an instructor with email "instructor@example.com" and password "abcdef"
    When I navigate to the referral page
    And I fill in the recipient's email with "newuser@example.com"
    And Instructor Referral: I click the "Refer" button
    Then a unique referral link should be generated and displayed

  Scenario: Showing error when an invalid email is given
    Given I am logged in as an instructor with email "instructor@example.com" and password "abcdef"
    When I navigate to the referral page
    And I fill in the recipient's email with " "
    And Instructor Referral: I click the "Refer" button
    Then Instructor Referral: Errors are displayed

  Scenario: New user accessing the signup page through the referral link
    Given I receive a referral link from "instructor@example.com"
    When I click the referral link
    Then I should be redirected to the signup page

    Scenario: New user accessing the signup page through an invalid referral link
    Given I have an invalid link
    When I click the referral link
    Then I should see invalid error

    Scenario: New user accessing the signup page through a expired referral link
    Given I have an expired link from "instructor@example.com"
    When I click the referral link
    Then I should see invalid error