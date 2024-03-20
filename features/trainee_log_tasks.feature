Feature: Trainee Log tasks

 As a trainee,
  So that I can log my daily workout
	I want to log and view workout history I have completed

	Scenario: Trainee can see view task button
		Given I am a trainee with following challenges:
				| name       | startDate   | endDate     | tasks                   |
				| Challenge1 | 2023-10-02  | 2024-10-31  | Task 1, Task 2, Task 3  |
				| Challenge2 | 2023-09-11  | 2024-10-22  | Task 1, Task 2, Task 3  |
				| Challenge3 | 2023-09-15  | 2023-10-06  | Task 1, Task 2, Task 3  |
		Given I am Logged in with username 'testTrainee@gmail.com' and password 'abcdef'
		And I visit 'My Challenges'
		Then I should see 'View Task Table'

	Scenario: View Task Table directs to the task log screen
		Given I am a trainee with following challenges:
				| name       | startDate   | endDate     | tasks                   |
				| Challenge1 | 2023-10-02  | 2024-10-31  | Task 1, Task 2, Task 3  |
				| Challenge2 | 2023-09-11  | 2024-10-22  | Task 1, Task 2, Task 3  |
				| Challenge3 | 2023-09-15  | 2023-10-06  | Task 1, Task 2, Task 3  |
		Given I am Logged in with username 'testTrainee@gmail.com' and password 'abcdef'
		And I visit 'My Challenges'
		And I click on link "View Task Table" of "Challenge1"
		Then I should be redirected to view task table page for "Challenge1"

	Scenario: View Task Table directs to the task log screen
		Given I am a trainee with following challenges:
				| name       | startDate   | endDate     | tasks                   |
				| Challenge1 | 2023-10-02  | 2024-10-31  | Task 1, Task 2, Task 3  |
				| Challenge2 | 2023-09-11  | 2024-10-22  | Task 1, Task 2, Task 3  |
				| Challenge3 | 2023-09-15  | 2023-10-06  | Task 1, Task 2, Task 3  |
		Given I am Logged in with username 'testTrainee@gmail.com' and password 'abcdef'
		And I visit 'My Challenges'
		And I click on link "View Task Table" of "Challenge1"
		And I log "120" for "Task 1"
		And I click on "Log Tasks"
		Then I should see "120" logged for "Task 1"
		


		