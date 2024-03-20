Feature: Trainee Signup
    As a trainee
    I want to sign up
    To access the website

    Scenario: Signs up with valid information
        Given I am on the signup page
        When I fill in "full_name" with "new user"
        And I fill in "email" with "user@example.com"
        And I fill in "password" with "password123"
        And I fill in "password_confirmation" with "password123"
        And I fill in "height_feet" with "6"
        And I fill in "height_inches" with "9"
        And I fill in "weight" with "70"
        And I click the "Sign Up" button
        Then I should be on login page

    Scenario: Signs up with with empty name
        Given I am on the signup page
        When I fill in "full_name" with ""
        And I fill in "email" with "user@example.com"
        And I fill in "password" with "password123"
        And I fill in "password_confirmation" with "password123"
        And I fill in "height_feet" with "6"
        And I fill in "height_inches" with "9"
        And I fill in "weight" with "70"
        And I click the "Sign Up" button
        Then I should stay on the signup page

    Scenario: Signs up with password and confirmation mismatch
        Given I am on the signup page
        When I fill in "full_name" with "new user"
        And I fill in "email" with "user@example.com"
        And I fill in "password" with "password123"
        And I fill in "password_confirmation" with "different_password"
        And I fill in "height_feet" with "6"
        And I fill in "height_inches" with "9"
        And I fill in "weight" with "70"
        And I click the "Sign Up" button
        Then I should stay on the signup page
        And I should see an error message indicating that the password confirmation does not match the password