# frozen_string_literal: true

Given('there is a challenge {string} with the trainee {string} with the following details:') do |_challenge_name, trainee_name, table|
  user = User.create!(email: 'testInstructor@gmail.com', password: 'abcdef', user_type: 'Instructor')
  trainee_user = User.create!(email: 'tempTrainee1@gmail.com', password: 'abcdef', user_type: 'Trainee')

  instructor = Instructor.create!(user:, first_name: 'John', last_name: 'Doe')
  trainee = Trainee.create!(user: trainee_user, full_name: trainee_name, height_feet: 6, height_inches: 9, weight: 55)

  table.hashes.each do |challenge|
    challenge_create = Challenge.create!(name: challenge['name'], startDate: challenge['startDate'], endDate: challenge['endDate'], instructor:, tasks_attributes: {
                                           '0' => { taskName: 'Task 1' },
                                           '1' => { taskName: 'Task 2' }
                                         })

    challenge_create.trainees << Trainee.where(id: trainee.id)

    tasks = challenge_create.tasks
    tasks.each do |task|
      (challenge_create.startDate..challenge_create.endDate).each do |date|
        tasktodo = TodolistTask.new(
          task:,
          trainee:,
          challenge: @challenge,
          date:
        )
        tasktodo.save
      end
    end
  end
end

Given('I am logged in as Instructor') do
  visit login_path
  expect(page).to have_content('User Sign in')
  fill_in 'email', with: 'testInstructor@gmail.com'
  fill_in 'password', with: 'abcdef'
  click_button 'Sign In'
  expect(page).to have_content('Welcome, John')
end

When('I visit the edit page for trainee {string} and challenge {string}') do |trainee_name, challenge_name|
  trainee = Trainee.find_by(full_name: trainee_name)
  challenge = Challenge.find_by(name: challenge_name)

  visit "/trainees/#{trainee.id}/edit_todo_list/#{challenge.id}"
end

When('I update the task list with the following tasks:') do |table|
  table.hashes.each_with_index do |_row, _index|
    within('#update-todo-list-form') do
      all('input[name^="todo_list[tasks_attributes]"]').each_with_index do |task_field, index|
        task_field.fill_in(with: table.hashes[index]['tasks'])
      end
    end
  end

  click_button 'Update'
end

When('I select the end date as {string}') do |date|
  fill_in 'end_date', with: date
end

Then('I should be redirected to the edit page for {string} and {string}') do |trainee_name, challenge_name|
  trainee = Trainee.find_by(full_name: trainee_name)
  challenge = Challenge.find_by(name: challenge_name)

  expect(current_path).to eq(edit_trainee_todo_list_path(trainee, challenge))
end

Then('I should see a flash notice with the message {string}') do |message|
  expect(page).to have_content(message.to_s)
end
