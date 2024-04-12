# frozen_string_literal: true

# features/step_definitions/logout_steps.rb

# Scenario: User logs out successfully
# Given I am a logged-in user
# Then I should see a "Sign out" button
# Then I click the "Sign out" button
# Then I should see a message "You have been signed out"
# And I should be redirected to the home page
# And I should not see a "Sign out" button

Given('I am a logged-in user') do
  user = User.create(email: 'Admin@gmail.com', password: 'Admin@123', user_type: 'Instructor')
  Instructor.create(user_id: user.id, first_name: 'admin', last_name: 'admin_last_name')
  visit login_path
  expect(page).to have_content('User Sign in')
  fill_in 'Email', with: 'Admin@gmail.com'
  fill_in 'Password', with: 'Admin@123'
  click_button 'Sign In'
end

Given('I am not logged in') do
  visit login_path
  expect(page).to have_content('User Sign in')
end

Then('I should see a {string} button') do |button_text|
  expect(page).to have_content(button_text)
end

When('I click the {string} button') do |button_text|
  click_on button_text
end

And('I should see a message {string}') do |message|
  expect(page).to have_content(message)
end

Then('I should be redirected to the home page') do
  expect("https://example.com#{current_path}").to eq(new_session_url)
end

And('I should not see a {string} button') do |button_text|
  expect(page).not_to have_button(button_text)
end

When('I visit the signout page') do
  visit signout_path
end
