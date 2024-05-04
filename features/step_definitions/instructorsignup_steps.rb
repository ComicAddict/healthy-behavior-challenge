# frozen_string_literal: true

Given('I received email with referral link') do
  @user = User.create!(email: 'instructor@example.com', password: 'abcdef', user_type: 'Instructor')
  @instructor = Instructor.create!(first_name: 'instructor', last_name: 'instructor', user: @user)
  puts @user.email

  visit login_path
  expect(page).to have_content('User Sign in')
  fill_in 'email', with: 'instructor@example.com'
  fill_in 'password', with: 'abcdef'
  click_button 'Sign In'
  expect(page).to have_content('Welcome')

  # Implement the code to navigate to the referral page
  visit instructor_referral_path
  expect(page).to have_content('Please enter valid email to refer an instructor.')

  # Implement the code to fill in the recipient's email field with the provided email
  @recipient_email = 'newuser@example.com'
  fill_in 'email', with: 'newuser@example.com'

  # Implement the code to click the specified button
  find('#refer-button').click

  # Implement the code to verify that a unique referral link was generated and sent to the recipient's email
  puts @user.email
  @token = InstructorReferral.where(email: @recipient_email).order(created_at: :desc).first.token
  puts @token
  expect(page).to have_content(@token)

  @token = SecureRandom.uuid
  user = User.find_by(email: 'instructor@example.com')
  # Create a new referral associated with the user
  user.instructor_referrals.create(email: 'example@example.com', token: @token, is_used: false,
                                   expires: Date.today + 7.days)
  @referral_link = instructor_signup_path(token: @token)
  puts @referral_link
end

Given('I click the sent referral link and redirected to signup page') do
  visit @referral_link
  expect(page).to have_content('Sign up')
end

When('I fill in email with instructorsignup3@gmail.com') do
  fill_in 'Email', with: 'instructorsignup3@gmail.com'
end

When('I fill in email with instructorsignup4@gmail.com') do
  fill_in 'Email', with: 'instructorsignup4@gmail.com'
end

When('I fill in email with {string}') do |email|
  fill_in 'Email', with: email
end

When('I fill in email with instructorsignup') do
  fill_in 'Email', with: 'instructorsignup'
end

When('I fill in email with ', ' ') do
  fill_in 'Email', with: ''
end

When('I fill in password with signup111') do
  fill_in 'Password', with: 'signup111'
end

When('I fill in password with {string}') do |password|
  fill_in 'Password', with: password
end

When('I fill in password with ', '') do
  fill_in 'Password', with: ''
end

When('I fill in confirm_password with signup111') do
  fill_in 'Confirm Password', with: 'signup111'
end

When('I fill in confirm_password with signup123') do
  fill_in 'Confirm Password', with: 'signup123'
end

When('I fill in confirm_password with {string}') do |confirm_password|
  fill_in 'Confirm Password', with: confirm_password
end

When('I fill in first_name with Peter') do
  fill_in 'First Name', with: 'Peter'
end

When('I fill in last_name with John') do
  fill_in 'Last Name', with: 'John'
end

When('I click on signup') do
  click_button 'Sign Up'
end

Then('I should see {string} page') do |msg|
  expect(page).to have_content(msg)
end

Then('I should see {string} message') do |msg|
  expect(page).to have_content(msg)
end
