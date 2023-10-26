Given('there is a challenge {string} with a trainee {string} and following details:') do |challenge_name, trainee_name, table|
    user = User.create!(email: 'testInstructor@gmail.com', password: 'abcdef', user_type: "Instructor")
    trainee_user = User.create!(email: 'tempTrainee1@gmail.com', password: 'abcdef', user_type: "Trainee")

    instructor = Instructor.create!(user: user, first_name: 'John', last_name: 'Doe')
    trainee = Trainee.create!(user: trainee_user, full_name: trainee_name, height: 150, weight: 55)

    table.hashes.each do |challenge|
        challenge_create = Challenge.create!(name: challenge['name'], startDate: challenge['startDate'], endDate: challenge['endDate'], instructor: instructor, tasks_attributes: {
            '0' => { taskName: 'Task 1' },
            '1' => { taskName: 'Task 2' }  
          })

        challenge_create.trainees << Trainee.where(id: trainee.id)
        challenge_trainee = ChallengeTrainee.new(challenge: @challenge, trainee: trainee)
        challenge_trainee.save

        tasks = challenge_create.tasks
        tasks.each do |task|
            (challenge_create.startDate..challenge_create.endDate).each do |date|
              tasktodo = TodolistTask.new(
                task: task,
                trainee: trainee,      
                challenge: @challenge, 
                date: date            
              )
                tasktodo.save   
            end
            genericlist = ChallengeGenericlist.new(
                task: task,
                challenge: @challenge,
            )
            genericlist.save
        end           
    end
  end
  
And('I am logged in as an Instructor') do
    visit login_path
    expect(page).to have_content('User Sign in')
    fill_in 'email', with: 'testInstructor@gmail.com'
    fill_in 'password', with: 'abcdef'
    click_button 'Sign In'
    expect(page).to have_content("Welcome, John")
end

When('I visit the edit page for challenge {string}') do |string|
    challenge = Challenge.find_by(name: string)
    visit "/challenges/#{challenge.id}/edit_todo_list"
end


Then('I should see the title {string}') do |string|
    expect(page).to have_content("#{string}")
end

Then('I should see the Start Date as {string}') do |string|
    expect(page).to have_content("#{string}")
end

Then('I should see the End Date as {string}') do |string|
    expect(page).to have_content("#{string}")
end

Given('I am logged in as a trainee') do
    visit login_path
    expect(page).to have_content('User Sign in')
    fill_in 'email', with: 'tempTrainee1@gmail.com'
    fill_in 'password', with: 'abcdef'
    click_button 'Sign In'
end

Then('I should be at the home page and see {string}') do |string|
    expect(page).to have_content("#{string}")
end
