# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.describe ChallengesController, type: :controller do
  after(:all) do
    ChallengeTrainee.destroy_all
    ChallengeGenericlist.destroy_all
    Challenge.destroy_all
    Trainee.destroy_all
  end

  before(:each) do
    @user = User.create(email: 'instructor@example.com', password: 'password', user_type: 'Instructor')

    @user2 = User.create(email: 'trainee@example.com', password: 'password', user_type: 'Trainee')

    # Create an instructor instance
    @instructor = Instructor.create(user: @user, first_name: 'John', last_name: 'Doe')

    @trainee = Trainee.create(user: @user, full_name: 'John Doe', height_feet: 4, height_inches: 10, weight: 65)
    session[:user_id] = @user.id
  end

  describe 'GET #new' do
    context 'when user is not signed in' do
      before do
        session[:user_id] = nil
      end

      it 'sets an alert flash message' do
        get :new
        expect(flash[:alert]).to eq('You must be signed in to access this page.')
      end
    end

    it 'assigns a new challenge' do
      get :new
      expect(assigns(:challenge)).to be_a_new(Challenge)
    end

    it 'redirects to root_path if the user is not an instructor' do
      session[:user_id] = @user2.id
      get :new
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('You are not an instructor.')
    end

    it 'assigns @is_instructor to true if the user is an instructor' do
      session[:user_id] = @instructor.user_id
      get :new
      expect(assigns(:is_instructor)).to eq(true)
    end
  end

  describe 'POST #create' do
    context 'when the user is an instructor' do
      it 'creates a new challenge with valid params' do
        session[:user_id] = @instructor.user_id
        post :create, params: { challenge: valid_params }
        expect(response).to redirect_to(new_challenge_path)
        expect(flash[:notice]).to eq('Challenge successfully created.')
      end

      it 'redirects to new_challenge_path with alert if the challenge name already exists' do
        session[:user_id] = @instructor.user_id
        post :create, params: { challenge: valid_params }
        post :create, params: { challenge: valid_params }
        expect(response).to redirect_to(new_challenge_path)
        expect(flash[:alert]).to eq('A challenge with the same name already exists.')
      end
    end

    it 'sets a flash message and redirects to the new challenge page' do
      session[:user_id] = @instructor.user_id

      # Prepare invalid challenge data with start date > end date
      challenge_params = {
        challenge: {
          name: 'Test Challenge',
          startDate: '2023-10-10',
          endDate: '2023-10-01' # Start date is greater than end date
        }
      }

      post :create, params: challenge_params

      # Expect flash message and redirection
      expect(flash[:alert]).to eq('start date is greater than end date')
      expect(response).to redirect_to(new_challenge_path)
    end
  end

  describe 'GET #add_trainees' do
    it 'assigns @challenge if the challenge has not started' do
      session[:user_id] = @instructor.user_id
      @challenge = Challenge.create(name: 'Test Challenge', startDate: Date.tomorrow, endDate: Date.tomorrow + 1)
      @challenge.instructor = @instructor
      @challenge.save
      get :add_trainees, params: { id: @challenge.id }
      expect(assigns(:challenge)).to eq(@challenge)
    end
  end

  describe 'POST #update_trainees' do
    it 'assigns @challenge if the challenge has not started' do
      session[:user_id] = @instructor.user_id
      @challenge = Challenge.create!(name: 'Test Challenge', startDate: Date.tomorrow + 1, endDate: Date.tomorrow + 10, instructor: @instructor, tasks_attributes: {
                                       '0' => { taskName: 'Task 1' },
                                       '1' => { taskName: 'Task 1' }
                                     })
      @challenge.instructor = @instructor
      @challenge.save
      @trainee1 = Trainee.create!(full_name: 'Trainee 1', height_feet: 5, height_inches: 9, weight: 1.5, user: @user2)
      @trainee1.save

      get :add_trainees, params: { id: @challenge.id }
      expect(assigns(:challenge)).to eq(@challenge)
      post :update_trainees, params: { id: @challenge.id, trainee_ids: [@trainee1.id] }
      expect(flash.now[:notice]).to eq('Trainees were successfully added to the challenge.')
    end

    it 'shows error message if no trainee selected to add to the challenge' do
      session[:user_id] = @instructor.user_id
      @challenge = Challenge.create!(name: 'Test Challenge', startDate: Date.tomorrow + 1, endDate: Date.tomorrow + 10, instructor: @instructor, tasks_attributes: {
                                       '0' => { taskName: 'Task 1' },
                                       '1' => { taskName: 'Task 1' }
                                     })
      @challenge.instructor = @instructor
      @challenge.save

      get :add_trainees, params: { id: @challenge.id }
      expect(assigns(:challenge)).to eq(@challenge)
      post :update_trainees, params: { id: @challenge.id, trainee_ids: [''] }
      expect(flash.now[:alert]).to eq('No trainee selected. Please select at least one trainee.')
    end

    it 'adds trainees to the challenge' do
      session[:user_id] = @instructor.user_id
      @challenge = Challenge.create!(name: 'ex chall', startDate: '2023-10-15', endDate: '2023-10-30', instructor: @instructor, tasks_attributes: {
                                       '0' => { taskName: 'Task 1' },
                                       '1' => { taskName: 'Task 1' }
                                     })
      @challenge.instructor = @instructor
      @challenge.save
      @trainee1 = Trainee.create!(full_name: 'Trainee 1', height_feet: 5, height_inches: 3, weight: 1.5, user: @user2)
      post :update_trainees, params: { id: @challenge.id, trainee_ids: [@trainee1.id] }

      expect(@challenge.trainees).to include(@trainee1)
    end

    it 'creates TodolistTasks for the trainees' do
      session[:user_id] = @instructor.user_id
      @challenge = Challenge.create!(name: 'ex chall', startDate: '2023-10-15', endDate: '2023-10-30', instructor: @instructor, tasks_attributes: {
                                       '0' => { taskName: 'Task 1' },
                                       '1' => { taskName: 'Task 1' }
                                     })
      @challenge.instructor = @instructor
      @challenge.save
      @trainee1 = Trainee.create!(full_name: 'Trainee 1', height_feet: 5, height_inches: 5, weight: 1.5, user: @user2)
      post :update_trainees, params: { id: @challenge.id, trainee_ids: [@trainee1.id] }

      todolist_task = TodolistTask.find_by(trainee: @trainee1, challenge: @challenge)
      expect(todolist_task).to be_present
    end

    it 'returns a successful response' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    it 'assigns @challenge and @todo_list for a challenge' do
      session[:user_id] = @instructor.user_id

      @challenge = Challenge.create(name: 'Test Challenge', startDate: Date.today, endDate: Date.tomorrow + 1)
      @challenge.instructor = @instructor
      @challenge.save

      @task = Task.create(taskName: 'Task 1')
      @task.save

      @challengeGenList = ChallengeGenericlist.create(task: @task, challenge: @challenge)
      @challengeGenList.save

      get :edit, params: { id: @challenge.id }

      expect(assigns(:challenge)).to eq(@challenge)

      task = Task.where(id: @task.id)
      expect(assigns(:todo_list)).to eq(task)
    end

    it 'redirects to root_path if the user is not an instructor' do
      session[:user_id] = @instructor.user_id

      @challenge = Challenge.create(name: 'Test Challenge', startDate: Date.tomorrow, endDate: Date.tomorrow + 1)
      @challenge.instructor = @instructor
      @challenge.save

      session[:user_id] = @user2.id

      get :edit, params: { id: @challenge.id }

      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq('You are not an instructor.')
    end
  end

  describe 'POST #update' do
    it 'cannot update challenge if it has already ended' do
      session[:user_id] = @instructor.user_id

      @challenge = Challenge.create(name: 'Test Challenge', startDate: Date.today - 4, endDate: Date.today - 1)
      @challenge.instructor = @instructor
      @challenge.save

      @task = Task.create(taskName: 'Task 1')
      @task.save

      @challengeGenList = ChallengeGenericlist.create(task: @task, challenge: @challenge)
      @challengeGenList.save

      post :update, params: { id: @challenge.id }

      expect(assigns(:challenge)).to eq(@challenge)
      expect(flash[:alert]).to eq('Challenge has already ended. You cannot edit it')
    end

    it 'update challenge if it has already started' do
      session[:user_id] = @instructor.user_id

      @challenge = Challenge.create(name: 'Test Challenge', startDate: Date.today - 1, endDate: Date.tomorrow + 1)
      @challenge.instructor = @instructor
      @challenge.save

      @task = Task.create(taskName: 'Task 1')
      @task.save

      @challengeGenList = ChallengeGenericlist.create(task: @task, challenge: @challenge)
      @challengeGenList.save

      @chall_trainee = ChallengeTrainee.create(challenge: @challenge, trainee: @trainee)
      @chall_trainee.save

      task_params = { taskName: 'New Task' }

      @task2 = Task.create(taskName: 'Task 2')
      @task2.save

      task_params_2 = { taskName: 'New Task 2' }

      post :update, params: {
        id: @challenge.id,
        task: { start_date: Date.today - 1, end_date: Date.tomorrow + 2, tasks: { @task.id => task_params } },
        tasks: { @task2.id => task_params_2 }
      }

      expect(response).to redirect_to(edit_challenge_path)
      expect(flash[:notice]).to eq('Challenge was successfully updated')
    end

    it 'deletes existing tasks' do
      session[:user_id] = @instructor.user_id

      @challenge = Challenge.create(name: 'Test Challenge', startDate: Date.today + 1, endDate: Date.tomorrow + 1)
      @challenge.instructor = @instructor
      @challenge.save

      @task = Task.create(taskName: 'Task 1')
      @task.save

      @challengeGenList = ChallengeGenericlist.create(task: @task, challenge: @challenge)
      @challengeGenList.save

      @chall_trainee = ChallengeTrainee.create(challenge: @challenge, trainee: @trainee)
      @chall_trainee.save

      @todo_list = TodolistTask.create(trainee: @trainee, challenge: @challenge, task: @task,
                                       date: @challenge.startDate)
      @todo_list.save

      post :update, params: {
        id: @challenge.id,
        task: { start_date: Date.today + 1, end_date: Date.tomorrow + 2 }
      }

      expect(TodolistTask.where(trainee: @trainee, challenge: @challenge).count).to eq(0)
    end
  end

  describe 'GET #show' do
    context 'when the user is an instructor' do
      it 'renders the show template' do
        session[:user_id] = @instructor.user_id
        @challenge = Challenge.create(name: 'Example Challenge', startDate: Date.today, endDate: Date.tomorrow)
        @challenge.instructor = @instructor
        @challenge.save

        get :show, params: { id: @challenge.id }
        expect(response).to render_template(:show)
      end

      it 'assigns the requested challenge' do
        session[:user_id] = @instructor.user_id
        @challenge = Challenge.create(name: 'Example Challenge', startDate: Date.today, endDate: Date.tomorrow)
        @challenge.instructor = @instructor
        @challenge.save

        get :show, params: { id: @challenge.id }
        expect(assigns(:challenge)).to eq(@challenge)
      end
    end
  end

  describe 'list trainees for a challenge' do
    it 'displays trainees for a challenge' do
      session[:user_id] = @instructor.user_id
      @challenge = Challenge.create!(name: 'ex chall', startDate: '2023-10-15', endDate: '2023-10-30', instructor: @instructor, tasks_attributes: {
                                       '0' => { taskName: 'Task 1' },
                                       '1' => { taskName: 'Task 1' }
                                     })
      user1 = User.create!(email: 'trainee22@example.com', password: 'abcdef', user_type: 'Trainee')
      user2 = User.create!(email: 'trainee233@example.com', password: 'abcdef', user_type: 'Trainee')
      user3 = User.create!(email: 'trainee322@example.com', password: 'abcdef', user_type: 'Trainee')
      @trainee1 = Trainee.create!(full_name: 'blah 1', user: user1, height_feet: 5, height_inches: 11, weight: 120)
      @trainee2 = Trainee.create!(full_name: 'blah 2', user: user2, height_feet: 4, height_inches: 10, weight: 120)
      @trainee3 = Trainee.create!(full_name: 'blah 3', user: user3, height_feet: 3, height_inches: 9, weight: 120)
      @challenge.trainees << [@trainee1, @trainee2, @trainee3]
      get :trainees_list, params: {
        challenge_id: @challenge.id
      }, session: {
        user_id: @instructor.user_id
      }
      expect(response).to render_template(:trainees_list)
    end
  end
  describe 'GET task_progress' do
    it 'populates the required instance variables for instructor' do
      @challenge = Challenge.create!(name: 'ex chall', startDate: '2023-10-15', endDate: '2023-10-30', instructor: @instructor, tasks_attributes: {
                                       '0' => { taskName: 'Task 1' },
                                       '1' => { taskName: 'Task 1' }
                                     })

      user1 = User.create!(email: 'trainee22dfas@example.com', password: 'abcdef', user_type: 'Trainee')
      @trainee1 = Trainee.create!(full_name: 'blah 1dsad', user: user1, height_feet: 5, height_inches: 10, weight: 120)
      @task = Task.create!(taskName: 'drink water')
      @challenge.trainees << @trainee1
      TodolistTask.create!(trainee_id: @trainee1.id, task_id: @task.id, challenge_id: @challenge.id,
                           date: Date.today + 1, status: 'not_completed')
      get :task_progress, params: { trainee_id: @trainee1.id, id: @challenge }

      expect(assigns(:dates_completed)).not_to be_nil
      expect(assigns(:counts_completed)).not_to be_nil
      expect(assigns(:dates_not_completed)).not_to be_nil
      expect(assigns(:counts_not_completed)).not_to be_nil
      expect(assigns(:counts_total)).not_to be_nil
      expect(assigns(:dates_completed_week)).not_to be_nil
      expect(assigns(:counts_completed_week)).not_to be_nil
      expect(assigns(:dates_not_completed_week)).not_to be_nil
      expect(assigns(:counts_not_completed_week)).not_to be_nil
      expect(assigns(:counts_total_week)).not_to be_nil
      expect(assigns(:trainee)).not_to be_nil
      expect(assigns(:trainee_name)).not_to be_nil
      expect(assigns(:page_title)).to eq("Progress Overview: #{@trainee1.full_name}")
    end

    it 'populates the required instance variables for trainee' do
      @challenge = Challenge.create!(name: 'ex chall', startDate: Date.today - 10, endDate: Date.today + 10, instructor: @instructor, tasks_attributes: {
                                       '0' => { taskName: 'Task 1' },
                                       '1' => { taskName: 'Task 1' }
                                     })
      user1 = User.create!(email: 'trainee22dfas@example.com', password: 'abcdef', user_type: 'Trainee')
      @trainee1 = Trainee.create!(full_name: 'blah 1dsad', user: user1, height_feet: 6, height_inches: 2, weight: 120)
      @task = Task.create!(taskName: 'drink water')
      @challenge.trainees << @trainee1
      TodolistTask.create!(trainee_id: @trainee1.id, task_id: @task.id, challenge_id: @challenge.id,
                           date: Date.today + 1, status: 'not_completed')
      TodolistTask.create!(trainee_id: @trainee1.id, task_id: @task.id, challenge_id: @challenge.id,
                           date: Date.today - 1, status: 'not_completed')
      TodolistTask.create!(trainee_id: @trainee1.id, task_id: @task.id, challenge_id: @challenge.id,
                           date: Date.today - 2, status: 'not_completed')

      session[:user_id] = @trainee1.user_id
      get :task_progress, params: { trainee_id: @trainee1.id, id: @challenge }

      expect(assigns(:dates_completed)).not_to be_nil
      expect(assigns(:counts_completed)).not_to be_nil
      expect(assigns(:dates_not_completed)).not_to be_nil
      expect(assigns(:counts_not_completed)).not_to be_nil
      expect(assigns(:counts_total)).not_to be_nil
      expect(assigns(:dates_completed_week)).not_to be_nil
      expect(assigns(:counts_completed_week)).not_to be_nil
      expect(assigns(:dates_not_completed_week)).not_to be_nil
      expect(assigns(:counts_not_completed_week)).not_to be_nil
      expect(assigns(:counts_total_week)).not_to be_nil
      expect(assigns(:trainee)).not_to be_nil
      expect(assigns(:trainee_name)).not_to be_nil
      expect(assigns(:page_title)).to eq("My Progress: #{@challenge.name}")
    end
  end

  describe 'GET show_challenge_trainee' do
    it 'assigns the challenge and trainee variables' do
      session[:user_id] = @instructor.user_id
      @challenge = Challenge.create!(name: 'ex chall', startDate: '2023-10-15', endDate: '2023-10-30', instructor: @instructor, tasks_attributes: {
                                       '0' => { taskName: 'Task 1' },
                                       '1' => { taskName: 'Task 1' }
                                     })

      user1 = User.create!(email: 'trainee22dfas@example.com', password: 'abcdef', user_type: 'Trainee')
      @trainee1 = Trainee.create!(full_name: 'blah 1dsad', user: user1, height_feet: 6, height_inches: 4, weight: 120)
      @task = Task.create!(taskName: 'drink water')
      @challenge.trainees << @trainee1
      TodolistTask.create!(trainee_id: @trainee1.id, task_id: @task.id, challenge_id: @challenge.id, date: Date.today + 1,
                           status: 'not_completed')
      get :show_challenge_trainee, params: { challenge_id: @challenge.id, trainee_id: @trainee1.id }
      expect(assigns(:challenge)).to eq(@challenge)
      expect(assigns(:trainee)).to eq(@trainee1)
    end

    it 'assigns the todo_list with filtered data' do
      session[:user_id] = @instructor.user_id
      @challenge = Challenge.create!(name: 'ex chall', startDate: '2023-10-15', endDate: '2024-10-30', instructor: @instructor, tasks_attributes: {
                                       '0' => { taskName: 'Task 1' },
                                       '1' => { taskName: 'Task 1' }
                                     })

      user1 = User.create!(email: 'trainee22dfas@example.com', password: 'abcdef', user_type: 'Trainee')
      @trainee1 = Trainee.create!(full_name: 'blah 1dsad', user: user1, height_feet: 9, height_inches: 1, weight: 120)
      @task = Task.create!(taskName: 'drink water')
      @challenge.trainees << @trainee1
      @todolist = TodolistTask.create!(trainee_id: @trainee1.id, task_id: @task.id, challenge_id: @challenge.id,
                                       date: Date.today, status: 'not_completed')
      get :show_challenge_trainee, params: { challenge_id: @challenge.id, trainee_id: @trainee1.id }
      actual_task_names = assigns(:todo_list).pluck(:taskName)
      expect(actual_task_names).to include(@task.taskName)
    end

    it 'renders the show_challenge_trainee template' do
      session[:user_id] = @instructor.user_id
      @challenge = Challenge.create!(name: 'ex chall', startDate: '2023-10-15', endDate: '2024-10-30', instructor: @instructor, tasks_attributes: {
                                       '0' => { taskName: 'Task 1' },
                                       '1' => { taskName: 'Task 1' }
                                     })

      user1 = User.create!(email: 'trainee22dfas@example.com', password: 'abcdef', user_type: 'Trainee')
      @trainee1 = Trainee.create!(full_name: 'blah 1dsad', user: user1, height_feet: 4, height_inches: 10, weight: 120)
      @task = Task.create!(taskName: 'drink water')
      @challenge.trainees << @trainee1
      @todolist = TodolistTask.create!(trainee_id: @trainee1.id, task_id: @task.id, challenge_id: @challenge.id,
                                       date: Date.today, status: 'not_completed')
      get :show_challenge_trainee, params: { challenge_id: @challenge.id, trainee_id: @trainee1.id }
      expect(response).to render_template('show_challenge_trainee')
    end
  end

  describe 'GET #filter_data' do
    let(:selected_date) { Date.today }

    it 'assigns @filtered_data' do
      user = User.create!(email: 'trainee12344@example.com', password: 'abcdef', user_type: 'Trainee')
      trainee = Trainee.create!(full_name: 'blah 1dsad', user:, height_feet: 6, height_inches: 0, weight: 120)
      session[:user_id] = @instructor.user_id
      challenge = Challenge.create!(name: 'ex chall', startDate: '2023-10-15', endDate: '2024-10-30', instructor: @instructor, tasks_attributes: {
                                      '0' => { taskName: 'Task 1' },
                                      '1' => { taskName: 'Task 1' }
                                    })
      task = Task.create(taskName: 'Task 1')
      create(:todolist_task, trainee:, challenge:, date: selected_date, task:)

      get :filter_data, params: { selected_date:, trainee_id: trainee.id, challenge_id: challenge.id }

      expect(assigns(:filtered_data)).to include(task)
    end

    it 'returns JSON response' do
      user = User.create!(email: 'trainee12344@example.com', password: 'abcdef', user_type: 'Trainee')
      trainee = Trainee.create!(full_name: 'blah 1dsad', user:, height_feet: 5, height_inches: 0, weight: 120)
      session[:user_id] = @instructor.user_id
      challenge = Challenge.create!(name: 'ex chall', startDate: '2023-10-15', endDate: '2024-10-30', instructor: @instructor, tasks_attributes: {
                                      '0' => { taskName: 'Task 1' },
                                      '1' => { taskName: 'Task 1' }
                                    })

      get :filter_data, params: { selected_date:, trainee_id: trainee.id, challenge_id: challenge.id }

      expect(response.content_type).to eq('application/json; charset=utf-8')
    end
  end

  describe 'DELETE #delete_trainee' do
    it 'deletes trainee and removes from the list' do
      session[:user_id] = @instructor.user_id
      @challenge = Challenge.create!(name: 'ex chall', startDate: Date.today + 7, endDate: Date.today + 13, instructor: @instructor, tasks_attributes: {
                                       '0' => { taskName: 'Task 1' },
                                       '1' => { taskName: 'Task 1' }
                                     })
      user1 = User.create!(email: 'trainee22@example.com', password: 'abcdef', user_type: 'Trainee')
      @trainee1 = Trainee.create!(full_name: 'blah 1', user: user1, height_feet: 5, height_inches: 6, weight: 120)
      @challenge.trainees << @trainee1
      delete :delete_trainee, params: {
        challenge_id: @challenge.id,
        trainee_id: @trainee1.id,
        id: @challenge.id
      }
      expect(response).to have_http_status(:redirect)
      expect(@challenge.trainees).not_to include(@trainee1)
    end
  end

  private

  def valid_params
    { name: 'New Challenge', startDate: '2023-10-15', endDate: '2023-10-30',
      tasks_attributes: { '0' => { taskName: 'Task 1' }, '1' => { taskName: 'Task 1' } } }
  end
end
