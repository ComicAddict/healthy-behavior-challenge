# frozen_string_literal: true

Given('I am an instructor with a trainee {string} and following challenges:') do |string, table|
  user = User.create!(email: 'testInstructor@gmail.com', password: 'abcdef', user_type: 'Instructor')
  trainee_user = User.create!(email: 'testTrainee3@gmail.com', password: 'abcdef', user_type: 'Trainee')
  instructor = Instructor.create!(user:, first_name: 'John', last_name: 'Doe')
  trainee = Trainee.create!(user: trainee_user, full_name: string, height_feet: 5, height_inches: 6, weight: 11)
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

Given('I am an instructor with a trainee {string} and an Ongoing Challenge {string}') do |string, string2|
  user = User.create!(email: 'testInstructor@gmail.com', password: 'abcdef', user_type: 'Instructor')
  trainee_user = User.create!(email: 'testTrainee2@gmail.com', password: 'abcdef', user_type: 'Trainee')
  instructor = Instructor.create!(user:, first_name: 'John', last_name: 'Doe')
  trainee = Trainee.create!(user: trainee_user, full_name: string, height_feet: 4, height_inches: 10, weight: 11)
  puts trainee.id
  challenge_create = Challenge.create!(name: string2, startDate: Date.today - 2, endDate: Date.today + 2, instructor:, tasks_attributes: {
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

Given('I am an instructor with a trainee {string} and a Future Challenge {string} with start date of tomorrow') do |string, string2|
  user = User.create!(email: 'testInstructor@gmail.com', password: 'abcdef', user_type: 'Instructor')
  trainee_user = User.create!(email: 'testTrainee1@gmail.com', password: 'abcdef', user_type: 'Trainee')
  instructor = Instructor.create!(user:, first_name: 'John', last_name: 'Doe')
  trainee = Trainee.create!(user: trainee_user, full_name: string, height_feet: 6, height_inches: 0, weight: 11)
  puts trainee.id
  challenge_create = Challenge.create!(name: string2, startDate: Date.today + 2, endDate: Date.today + 4, instructor:, tasks_attributes: {
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

Then('I should see Current Date') do
  date_picker_input = find('#datePicker')

  actual_date = date_picker_input.value

  expect(actual_date).to eq(Date.today)
end

Then('I should see {string} date') do |date|
  date_picker_input = find('#datePicker')

  date_picker_input.value

  expect(page).to have_content(date)
end

Then('I should see tomorrows date') do
  date_picker_input = find('#datePicker')

  actual_date = date_picker_input.value

  expect(actual_date).to eq(Date.today + 1)
end

Given('I follow View TodoList for {string}') do |_string|
  trainee = Trainee.find_by(full_name: 'TestTrainee')
  challenge = Challenge.find_by(name: 'Challenge1')
  visit show_challenge_trainee_path(challenge_id: challenge.id, trainee_id: trainee.id)
end
