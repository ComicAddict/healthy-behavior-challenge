Feature: View Total Best Days count

    Scenario: View Total Best Days for a previous challenge
        Given I am logged in as trainee
        When I visit the Daily Todo List page
        And I select one of the dates from previous challenge
        And I click "Show Tasks" button
        Then I should see the Best Days for the whole challenge

    Scenario: View Total Best Days for ongoing challenge
        Given I am logged in as trainee
        When I visit the Daily Todo List page
        And I select today's date
        And I click "Show Tasks" button
        Then I should see the Best Days for the ongoing challenge

    Scenario: Viewing tasks for current day
        Given I am logged in as trainee
        When I visit the Daily Todo List page
        And I select today's date
        Then I should see Current Date