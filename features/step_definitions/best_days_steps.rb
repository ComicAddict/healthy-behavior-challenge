# frozen_string_literal: true

Given('I am logged in as trainee') do
  @user = User.create!(email: 'traineetest@example.com', password: 'asdf', user_type: 'trainee')
  @trainee = Trainee.create!(full_name: 'traineetest', height_feet: 5, height_inches: 9, weight: 85, user_id: @user.id)

  visit login_path
  expect(page).to have_content('User Sign in')
  fill_in 'email', with: 'traineetest@example.com'
  fill_in 'password', with: 'asdf'
  click_button 'Sign In'
  expect(page).to have_content('Daily Todo List')
end

When('I select one of the dates from previous challenge') do
  @user = User.create!(email: 'instructor@example.com', password: 'asdf', user_type: 'Instructor')
  @instructor = Instructor.create!(first_name: 'fn', last_name: 'ln', user_id: @user.id)

  @challenge = Challenge.create!(name: 'challenge', startDate: Date.today - 3, endDate: Date.today - 1,
                                 instructor_id: @instructor.id)
  @challengetrainee = ChallengeTrainee.create!(trainee_id: @trainee.id, challenge_id: @challenge.id)

  @task1 = Task.create!(taskName: 'exercise')
  @task2 = Task.create!(taskName: 'steps')

  TodolistTask.create!(task_id: @task1.id, status: 'completed', trainee_id: @trainee.id, challenge_id: @challenge.id,
                       date: Date.today - 3)
  TodolistTask.create!(task_id: @task2.id, status: 'completed', trainee_id: @trainee.id, challenge_id: @challenge.id,
                       date: Date.today - 3)
  TodolistTask.create!(task_id: @task1.id, status: 'completed', trainee_id: @trainee.id, challenge_id: @challenge.id,
                       date: Date.today - 2)
  TodolistTask.create!(task_id: @task2.id, status: 'not_completed', trainee_id: @trainee.id,
                       challenge_id: @challenge.id, date: Date.today - 2)
  TodolistTask.create!(task_id: @task1.id, status: 'not_completed', trainee_id: @trainee.id,
                       challenge_id: @challenge.id, date: Date.today - 1)
  TodolistTask.create!(task_id: @task2.id, status: 'not_completed', trainee_id: @trainee.id,
                       challenge_id: @challenge.id, date: Date.today - 1)

  previous_date = (Date.today - 2).strftime('%Y-%m-%d')
  find('input[type="date"]').set(previous_date)
end

Then('I should see the Best Days for the whole challenge') do
  expect(page).to have_content('🎯 1')
end

When("I select today's date") do
  @user = User.create!(email: 'instructor@example.com', password: 'asdf', user_type: 'Instructor')
  @instructor = Instructor.create!(first_name: 'fn', last_name: 'ln', user_id: @user.id)

  @challenge = Challenge.create!(name: 'challenge', startDate: Date.today - 2, endDate: Date.today + 1,
                                 instructor_id: @instructor.id)
  @challengetrainee = ChallengeTrainee.create!(trainee_id: @trainee.id, challenge_id: @challenge.id)

  @task1 = Task.create!(taskName: 'exercise')
  @task2 = Task.create!(taskName: 'steps')

  TodolistTask.create!(task_id: @task1.id, status: 'completed', trainee_id: @trainee.id, challenge_id: @challenge.id,
                       date: Date.today - 2)
  TodolistTask.create!(task_id: @task2.id, status: 'completed', trainee_id: @trainee.id, challenge_id: @challenge.id,
                       date: Date.today - 2)
  TodolistTask.create!(task_id: @task1.id, status: 'completed', trainee_id: @trainee.id, challenge_id: @challenge.id,
                       date: Date.today - 1)
  TodolistTask.create!(task_id: @task2.id, status: 'completed', trainee_id: @trainee.id, challenge_id: @challenge.id,
                       date: Date.today - 1)
  TodolistTask.create!(task_id: @task1.id, status: 'not_completed', trainee_id: @trainee.id,
                       challenge_id: @challenge.id, date: Date.today)
  TodolistTask.create!(task_id: @task2.id, status: 'not_completed', trainee_id: @trainee.id,
                       challenge_id: @challenge.id, date: Date.today)

  todays_date = Date.today.strftime('%Y-%m-%d')
  find('input[type="date"]').set(todays_date)
end

Then('I should see the Best Days for the ongoing challenge') do
  expect(page).to have_content('🎯 2')
end
