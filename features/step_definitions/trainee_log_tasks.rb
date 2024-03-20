# frozen_string_literal: true

When('I click on link {string} of {string}') do |button, element|
  find("[id='#{element}#{button}']").click
end

Then('I should be redirected to view task table page for {string}') do |challenge_name|
  challenge = Challenge.find_by(name: challenge_name)
  expect(current_path).to eq(view_challenge_tasks_detail_path(challenge.id))
end

When('I log {string} for {string}') do |_value, _entry|
  pending
end

Then('I should see {string} logged for {string}') do |_value, _entry|
  pending
end
