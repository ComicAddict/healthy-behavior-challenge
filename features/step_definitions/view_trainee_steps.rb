# frozen_string_literal: true

Given('I have instructor access') do
  user = User.create!(email: 'instructor@example.com', password: 'abcdef', user_type: 'Instructor')
  Instructor.create(user:, first_name: 'John', last_name: 'Doe')

  visit root_path
  fill_in 'Email', with: user.email
  fill_in 'Password', with: user.password
  click_button 'Sign In'
end

Given('I am on the homepage') do
  visit root_path
end

When("I click on the 'View Trainees' link") do
  click_link 'View Trainees'
end

Then("I should be on the 'View Trainees' page") do
  expect(page).to have_current_path(view_trainees_path)
  expect(page).to have_content('View Trainees Page')
end

Given('I am on the "View Trainees" page with at least one trainee') do
  instructor_user = User.create!(email: 'testinstructor@example.com', password: 'securepassword',
                                 user_type: 'Instructor')
  instructor = Instructor.create!(user: instructor_user, first_name: 'Some', last_name: 'Body')

  trainee_user = User.create!(email: 'trainee@example.com', password: 'password', user_type: 'Trainee')
  trainee = Trainee.create!(user: trainee_user, full_name: 'Trainee Name', height_feet: 6, height_inches: 10,
                            weight: 75)

  @challenge = Challenge.create!(name: 'Challenge Name', startDate: Date.yesterday, endDate: Date.tomorrow,
                                 instructor:)
  ChallengeTrainee.create!(trainee:, challenge: @challenge)

  @task = Task.create!(taskName: 'Task Name')
  TodolistTask.create!(task: @task, challenge: @challenge, trainee:, status: 'completed', date: Date.today)

  visit view_trainees_path
end

When('I click on the "View Profile" button for the first trainee') do
  first(:link, 'View Profile').click
end

Then("I should be on that trainee's profile details page") do
  expect(page).to have_current_path(trainee_profile_details_path(Trainee.first))
end

Given("I am on a trainee's profile details page") do
  user = User.create!(email: 'instructor@example.com', password: 'abcdef', user_type: 'Instructor')
  Instructor.create(user:, first_name: 'John', last_name: 'Doe')
  trainee_user = User.create!(email: 'trainee@example.com', password: 'password', user_type: 'Trainee')
  Trainee.create!(user: trainee_user, full_name: 'Trainee Name', height_feet: 5, height_inches: 9, weight: 75)

  visit root_path
  fill_in 'Email', with: user.email
  fill_in 'Password', with: 'abcdef'
  click_button 'Sign In'

  visit view_trainees_path
  first(:link, 'View Profile').click
end

When('I click on the {string} button') do |button_text|
  click_link button_text
end

Then('I should be back on the {string} page') do |page_name|
  expected_path = case page_name
                  when 'View Trainees' then view_trainees_path
                  end
  expect(page).to have_current_path(expected_path)
end

Given(/^I am on the "([^"]*)" page$/) do |page_name|
  case page_name
  when 'View Trainees'
    visit view_trainees_path
  end
end

When('I attempt to view a profile for a non-existent trainee') do
  visit '/view_trainees/non-existent-id/profile_details'
end

Then('I should see an error message indicating the trainee does not exist') do
  expect(page).to have_content('Trainee not found.')
end

Given('no trainees exist') do
  Trainee.delete_all
end

Then('I should see a message indicating there are no trainees to display') do
  expect(page).to have_content('No Trainees.')
end

When('I click on the "Challenges" button for the first trainee') do
  first(:link, 'Challenges').click
end

Then("I should be on that trainee's challenges page") do
  expect(page).to have_current_path(trainee_challenges_path(Trainee.first))
  expect(page).to have_content(@challenge.name)
  expect(page).to have_content(@challenge.startDate.strftime('%Y-%m-%d'))
  expect(page).to have_content(@challenge.endDate.strftime('%Y-%m-%d'))
end

When('I click on the "Progress" button for the first challenge') do
  first(:link, 'Progress').click
end

Then("I should be on that challenge's progress page for the trainee") do
  expect(page).to have_current_path(trainee_challenge_progress_path(Trainee.first, Challenge.first))
  expect(page).to have_content("#{Trainee.first.full_name}'s Progress")
  expect(page).to have_content("in #{Challenge.first.name}")
  Challenge.first.tasks.each do |task|
    expect(page).to have_content(task.taskName)
  end
end

Given('I am on the "View Trainees" page with at least one trainee but no challenges') do
  trainee_user = User.create!(email: 'traineewithnochallenges@example.com', password: 'password', user_type: 'Trainee')
  @trainee = Trainee.create!(user: trainee_user, full_name: 'Trainee Name', height_feet: 6, height_inches: 10,
                             weight: 75)
  visit view_trainees_path
end

Then('I should see messages indicating there are no current or past challenges') do
  expect(page).to have_content('No Current Challenges')
  expect(page).to have_content('No Past Challenges')
end

Then('I should be back on that trainee\'s challenges page') do
  expect(page).to have_current_path(trainee_challenges_path(Trainee.first))
  expect(page).to have_content('Current Challenges')
  expect(page).to have_content('Past Challenges')
end
