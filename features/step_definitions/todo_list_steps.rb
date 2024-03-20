# frozen_string_literal: true

# features/step_definitions/todo_list_steps.rb

Given('I am logged in') do
  @user2 = User.create!(email: 'instructor@example.com', password: 'abcdef', user_type: 'Instructor')
  @instructor = Instructor.create!(user_id: @user2.id, first_name: 'instructor1', last_name: 'instructor_last_name')

  @user = User.create!(email: 'traineetest@example.com', password: 'asdf', user_type: 'trainee')
  @trainee = Trainee.create!(full_name: 'trainee1', height_feet: 6, height_inches: 9, weight: 85, user_id: @user.id)

  @challenge1 = Challenge.create!(name: 'challenge', startDate: Date.today - 2, endDate: Date.today + 1,
                                  instructor_id: @instructor.id)
  @challengetrainee = ChallengeTrainee.create!(trainee_id: @trainee.id, challenge_id: @challenge1.id)
  @task1 = Task.create!(taskName: 'exercise')
  @task2 = Task.create!(taskName: 'steps')
  @todolisttask = TodolistTask.create!(task_id: @task1.id, status: 'not_completed', trainee_id: @trainee.id,
                                       challenge_id: @challenge1.id, date: Date.today)
  TodolistTask.create!(task_id: @task2.id, status: 'not_completed', trainee_id: @trainee.id,
                       challenge_id: @challenge1.id, date: Date.today)
  TodolistTask.create!(task_id: @task1.id, status: 'not_completed', trainee_id: @trainee.id,
                       challenge_id: @challenge1.id, date: Date.today - 1)
  TodolistTask.create!(task_id: @task2.id, status: 'not_completed', trainee_id: @trainee.id,
                       challenge_id: @challenge1.id, date: Date.today - 1)

  puts @user.email
  visit login_path
  expect(page).to have_content('User Sign in')
  fill_in 'email', with: 'traineetest@example.com'
  fill_in 'password', with: 'asdf'
  click_button 'Sign In'
  expect(page).to have_content('Daily Todo List')
  puts @user.id
end

When('I click on link {string}') do |string|
  click_link(string)
end

Then('I should be on the todo list page') do
  expect(page).to have_current_path(todo_list_path, ignore_query: true)
end

When('I check the {string} checkbox for a task') do |string|
  task_id = Task.find_by(taskName: string).id
  puts "Task ID: #{task_id}"
  wait = Selenium::WebDriver::Wait.new(timeout: 10)
  checkbox = wait.until { find("input[name='user[tasks[#{task_id}][completed]]']") }
  checkbox.check
end

When('I click button {string}') do |string|
  click_button(string)
end

Then('I should be able to see a notice {string}') do |string|
  expect(page).to have_content(string)
end

Then('I should be able to see {string}') do |content|
  expect(page).to have_content(content)
end

And('I should see {string} in a strikethrough') do |content|
  expect(page).to have_css('s', text: content)
end

Then('I should see a date selector') do
  expect(page).to have_selector('input[type="date"]')
end

When('I select the previous date using the date selector') do
  previous_date = (Date.today - 1).strftime('%Y-%m-%d')
  find('input[type="date"]').set(previous_date)
end

When('the time is past 3 AM') do
  current_time = Time.now
  expect(current_time.hour).to be >= 3
end

Then('the "Mark as Completed" button should be disabled') do
  expect(page).to have_selector('input[type="submit"][value="Mark as Completed"][disabled]')
end

When('I visit the Daily Todo List page') do
  visit todo_list_path
  expect(page).to have_content('Daily Todo List')
end

When('I select a previous date from the date selector') do
  current_date = Date.today
  @previous_date = current_date - 1

  fill_in 'user_selected_date', with: @previous_date.strftime('%Y-%m-%d')
end

When('I click "Show Tasks" button') do
  click_button 'Show Tasks'
end

Then('I should see the Daily Todo List for the selected date') do
  displayed_date_element = find('p', text: 'Date:')
  displayed_date = displayed_date_element.text.gsub('Date: ', '')

  expected_date = @previous_date.strftime('%B %d, %Y')
  expect(displayed_date).to eq(expected_date)
end

Given('I am logged in as different user') do
  @user3 = User.create!(email: 'traineetest2@example.com', password: 'asdf', user_type: 'trainee')
  @trainee2 = Trainee.create!(full_name: 'trainee2', height_feet: 6, height_inches: 9, weight: 85, user_id: @user3.id)

  @user4 = User.create!(email: 'instructor2@example.com', password: 'abcdef', user_type: 'Instructor')
  @instructor2 = Instructor.create(user_id: @user4.id, first_name: 'instructor2', last_name: 'instructor2_last_name')

  @challenge2 = Challenge.create!(name: 'challenge2', startDate: Date.today - 1, endDate: Date.today + 1,
                                  instructor_id: @instructor2.id)
  @challengetrainee = ChallengeTrainee.create!(trainee_id: @trainee2.id, challenge_id: @challenge2.id)

  visit login_path
  expect(page).to have_content('User Sign in')
  fill_in 'email', with: 'traineetest2@example.com'
  fill_in 'password', with: 'asdf'
  click_button 'Sign In'
  expect(page).to have_content('Daily Todo List')
end

And('I try to visit Daily To-Do List page') do
  visit todo_list_path
end

Given('I am logged in as instructor') do
  @user5 = User.create!(email: 'instructor3@example.com', password: 'abcdef', user_type: 'Instructor')
  @instructor3 = Instructor.create(user_id: @user5.id, first_name: 'instructor3', last_name: 'instructor3_last_name')
  @challenge3 = Challenge.create(name: 'challenge3', startDate: Date.today, endDate: Date.today,
                                 instructor_id: @instructor3.id)

  visit login_path
  expect(page).to have_content('User Sign in')
  fill_in 'email', with: 'instructor3@example.com'
  fill_in 'password', with: 'abcdef'
  click_button 'Sign In'
end

Then('I should be redirected to view progress page for {string}') do |string|
  expect(page).to have_content("My Progress: #{string}")
end
