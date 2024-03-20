# frozen_string_literal: true

Given('I am an instructor trying to add trainees to a challenge') do
  user = User.create!(email: 'instructor00@example.com', password: 'abcdef', user_type: 'Instructor')
  instructor = Instructor.create(user_id: user.id, first_name: 'John', last_name: 'Doe')

  user_2 = User.create!(email: 'trainee00@example.com', password: 'abcdefg', user_type: 'Trainee')
  user_3 = User.create!(email: 'trainee01@example.com', password: 'abcdefgh', user_type: 'Trainee')
  user_4 = User.create!(email: 'trainee02@example.com', password: 'abcdefgi', user_type: 'Trainee')

  trainee_1 = Trainee.create(full_name: 'Trainee1 Name', height_feet: 5, height_inches: 9, weight: 1,
                             user_id: user_2.id)
  Trainee.create(full_name: 'Trainee2 Name', height_feet: 5, height_inches: 9, weight: 2, user_id: user_3.id)
  Trainee.create(full_name: 'Trainee3 Name', height_feet: 5, height_inches: 9, weight: 2, user_id: user_4.id)

  # Use Capybara to log in as the user
  visit root_path
  fill_in 'Email', with: user.email
  fill_in 'Password', with: user.password
  click_button 'Sign In'

  challenge_1 = Challenge.create(name: 'Sample Challenge', startDate: Date.today + 2, endDate: Date.today + 5, instructor:, tasks_attributes: {
                                   '0' => { taskName: 'Task 1' },
                                   '1' => { taskName: 'Task 1' } # Use a different name for the second task
                                 })

  ChallengeTrainee.create(challenge_id: challenge_1.id, trainee_id: trainee_1.id)
end

When('I am on the Add Trainees page for {string}') do |challenge_name|
  challenge = Challenge.find_by(name: challenge_name)
  visit add_trainees_challenge_path(challenge.id)
end

And('I should see all trainees who are not in the challenge') do
  expect(page).to have_content('Trainee2 Name')
  expect(page).to have_content('Trainee3 Name')
end

Then('I select a trainee and add it to {string}') do |challenge_name|
  Challenge.find_by(name: challenge_name)
  # trainee_2 = Trainee.find_by(full_name:'Trainee2 Name')
  select 'Trainee2 Name', from: 'traineeSelect'

  # post update_trainees_challenge_path(challenge.id, {trainee_ids: [trainee_2.id]}) # Assuming this is a POST request
  # fill_in "traineeSearch", with: trainee_2.full_name # Assuming this is the input field for trainee_ids
end

And('I click on {string}') do |button_text|
  click_on button_text
end
