# frozen_string_literal: true

Given(/^A user is registered with the email "Admin@gmail.com" and password "Admin@123"$/) do
  user = User.create(email: 'Admin@gmail.com', password: 'Admin@123', user_type: 'Instructor')
  Instructor.create(user_id: user.id, first_name: 'instructor', last_name: 'instructor_last_name')
end

Given(/^A trainee is registered with the email "trainee@gmail.com" and password "trainee@123"$/) do
  user = User.create(email: 'trainee@gmail.com', password: 'trainee@123', user_type: 'Trainee')
  Trainee.create(full_name: 'trainee', height_feet: 6, height_inches: 9, weight: 85, user_id: user.id)
end

Given(/^I am not currently Logged in$/) do
  visit login_path
  expect(page).to have_content('User Sign in')
end

Given(/^I am on the Login page$/) do
  visit login_path
end

When('I enter Admin@gmail.com as email') do
  fill_in 'email', with: 'Admin@gmail.com'
end

When('I enter {string} as email') do |string|
  fill_in 'email', with: string
end

When('I enter '' as email') do
  fill_in 'email', with: ''
end

When('I enter Admin@123 as password') do
  fill_in 'password', with: 'Admin@123'
end

When('I enter '' as password') do
  fill_in 'password', with: ''
end

When('I enter {string} as password') do |string|
  fill_in 'password', with: string
end

When('I enter abcd@123 as password') do
  fill_in 'password', with: 'abcd@123'
end

When('I click on submit') do
  click_button 'Sign In'
end

Then('I should see {string}') do |arg|
  expect(page).to have_content(arg)
end
