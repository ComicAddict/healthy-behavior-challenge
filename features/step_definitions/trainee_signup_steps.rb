# frozen_string_literal: true

Given('I am on the signup page') do
  visit trainee_signup_path
end

When('I fill in "full_name" with "new user"') do
  fill_in 'user[full_name]', with: 'new user'
end

When('I fill in "email" with "user@example.com"') do
  fill_in 'user[email]', with: 'user@example.com'
end

When('I fill in "password" with "password123"') do
  fill_in 'user[password]', with: 'password123'
end

When('I fill in "password_confirmation" with "password123"') do
  fill_in 'user[password_confirmation]', with: 'password123'
end

When('I fill in "height_feet" with "6"') do
  fill_in 'user[height_feet]', with: '6'
end

When('I fill in "height_inches" with "9"') do
  fill_in 'user[height_inches]', with: '9'
end

When('I fill in "weight" with "70"') do
  fill_in 'user[weight]', with: '70'
end

When('I click the Sign Up button') do
  click_link 'New User? Sign Up as Trainee'
end

Then('I should be on login page') do
  expect(current_path).to eq(login_path)
end

When('I fill in "full_name" with ""') do
  fill_in 'user[full_name]', with: ''
end

Then('I should see an error message indicating that Full name can\'t be blank') do
  expect(page).to have_content("Full name can't be blank")
end

Then('I should stay on the signup page') do
  expect(current_path).to eq(trainee_signup_path)
end

When('I fill in "password_confirmation" with "different_password"') do
  fill_in 'user[password_confirmation]', with: 'different_password'
end

Then('I should see an error message indicating that the password confirmation does not match the password') do
  expect(page).to have_content("Password confirmation doesn't match Password")
end
