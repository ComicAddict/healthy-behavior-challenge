# frozen_string_literal: true

Given('I am a trainee with following challenges:') do |table|
  user_trainee = User.create!(email: 'testTrainee@gmail.com', password: 'abcdef', user_type: 'trainee')
  @trainee = Trainee.create!(full_name: 'trainee1', height_feet: 6, height_inches: 9, weight: 85,
                             user_id: user_trainee.id)

  user = User.create!(email: 'testInstructor@gmail.com', password: 'abcdef', user_type: 'Instructor')
  @instructor = Instructor.create!(user:, first_name: 'John', last_name: 'Doe')

  table.hashes.each do |challenge|
    challenge = Challenge.create!(name: challenge['name'], startDate: challenge['startDate'], endDate: challenge['endDate'], instructor: @instructor, tasks_attributes: {
                                    '0' => { taskName: 'Task 1' },
                                    '1' => { taskName: 'Task 1' }
                                  })
    challenge.trainees << Trainee.where(id: @trainee.id)
  end
end

Given('I visit {string}') do |_string|
  visit show_challenges_path
end
