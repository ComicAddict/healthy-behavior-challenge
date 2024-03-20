# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TodoListController, type: :controller do
  before do
    @user2 = User.create!(email: 'instructor2@example.com', password: 'abcdef', user_type: 'Instructor')
    @instructor = Instructor.create(user_id: @user2.id, first_name: 'instructor2', last_name: 'instructor2_last_name')

    @user = User.create!(email: 'traineetest2@example.com', password: 'asdf', user_type: 'trainee')
    @trainee = Trainee.create(full_name: 'trainee2', height_feet: 6, height_inches: 9, weight: 85, user_id: @user.id)

    start_date = Date.today
    end_date = start_date + 4.days
    @challenge2 = Challenge.create(name: 'challenge2', startDate: start_date, endDate: end_date,
                                   instructor_id: @instructor.id)

    start_date1 = Date.today + 4.days
    end_date1 = start_date1 + 4.days
    @challenge3 = Challenge.create(name: 'challenge3', startDate: start_date1, endDate: end_date1,
                                   instructor_id: @instructor.id)

    @challengetrainee = ChallengeTrainee.create(trainee_id: @trainee.id, challenge_id: @challenge2.id)

    tasks = [Task.create(taskName: 'Do 10 pushups'), Task.create(taskName: 'Walk 10000 steps')]
    tasks2 = [Task.create(taskName: 'Do 25 pullups'), Task.create(taskName: 'Drink 4 litres water')]

    (start_date..end_date).each do |date|
      tasks.each do |task|
        TodolistTask.create(task_id: task.id, status: 'not_completed', trainee_id: @trainee.id,
                            challenge_id: @challenge2.id, date:)
      end
    end

    (start_date1..end_date1).each do |date|
      tasks2.each do |task|
        TodolistTask.create(task_id: task.id, status: 'not_completed', trainee_id: @trainee.id,
                            challenge_id: @challenge3.id, date:)
      end
    end

    session[:user_id] = @user.id
  end

  describe 'GET #show' do
    it 'renders the show template' do
      get :show
      expect(response).to render_template(:show)
    end

    it 'displays the Daily Todo List for the selected date' do
      previous_date = Date.yesterday
      get :show, params: { selected_date: previous_date }
      expect(response).to render_template(:show)
      expect(assigns(:date)).to eq(previous_date)
    end
  end

  describe 'GET #edit' do
    context 'when user is an instructor' do
      it 'renders the edit template' do
        session[:user_id] = @instructor.user_id
        get :edit, params: { trainee_id: @trainee.id, challenge_id: @challenge2.id }
        expect(response).to render_template('edit')
      end

      it 'renders the edit template for future challenge' do
        session[:user_id] = @instructor.user_id
        get :edit, params: { trainee_id: @trainee.id, challenge_id: @challenge3.id }
        expect(response).to render_template('edit')
      end
    end

    context 'when user is not an instructor' do
      it 'redirects to the home page' do
        session[:user_id] = @trainee.user_id
        get :edit, params: { trainee_id: @trainee.id, challenge_id: @challengetrainee.challenge_id }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH #update' do
    context 'when user is an instructor' do
      it 'updates the task list with valid data' do
        session[:user_id] = @instructor.user_id

        task1_id = Task.find_by(taskName: 'Do 10 pushups').id
        task2_id = Task.find_by(taskName: 'Walk 10000 steps').id

        task_params = {
          start_date: Date.tomorrow,
          end_date: Date.tomorrow + 1.days,
          tasks: {
            task1_id => { taskName: 'Do 25 pullups' },
            task2_id => { taskName: 'Swim 0.5 hours' }
          }
        }

        tasks_params = {
          'new_1' => { taskName: 'New Task 1' },
          'new_2' => { taskName: 'Drink 4 litres water' }
        }

        patch :update,
              params: { trainee_id: @trainee.id, challenge_id: @challenge2.id, task: task_params, tasks: tasks_params }
        expect(response).to redirect_to(edit_trainee_todo_list_path(@trainee, @challenge2))
        expect(flash[:notice]).to eq('Tasks successfully updated.')
      end

      it 'redirects to the edit page with an error notice for invalid date range' do
        session[:user_id] = @instructor.user_id

        task_params = {
          start_date: Date.yesterday,
          end_date: Date.tomorrow + 5.days,
          tasks: {
            '1' => { taskName: 'Task 1' },
            '2' => { taskName: 'Task 2' }
          }
        }

        patch :update, params: { trainee_id: @trainee.id, challenge_id: @challenge2.id, task: task_params }
        expect(response).to redirect_to(edit_trainee_todo_list_path(@trainee, @challenge2))
        expect(flash[:notice]).to eq("Date range must be within the challenge's start and end dates.")
      end

      it 'redirects to the edit page with an error notice for invalid date range for ongoing challenge' do
        session[:user_id] = @instructor.user_id

        task_params = {
          start_date: Date.today,
          end_date: Date.tomorrow,
          tasks: {
            '1' => { taskName: 'Task 1' },
            '2' => { taskName: 'Task 2' }
          }
        }

        patch :update, params: { trainee_id: @trainee.id, challenge_id: @challenge2.id, task: task_params }
        expect(response).to redirect_to(edit_trainee_todo_list_path(@trainee, @challenge2))
        expect(flash[:notice]).to eq('Challenge has already started! Choose a start date from tomorrow onwards.')
      end
    end
  end

  describe 'POST #mark_as_completed' do
    it 'marks a task as completed and shows a notice' do
      session[:user_id] = @user.id
      task_data = {
        '1' => { task_id: 1, challenge_id: 1, date: Date.today, completed: '1' }
      }
      post :mark_as_completed, params: { user: { tasks: task_data } }
      expect(response).to redirect_to(todo_list_path(selected_date: Date.today))
      expect(flash[:notice]).to eq('Tasks have been updated.')
    end
  end
  describe '#calculate_streak' do
    let(:trainee_id) { @trainee.id }
    let(:challenge_id) { @challenge2.id }

    it 'calculates streak for completed tasks' do
      (Date.today..Date.today + 4.days).each do |date|
        TodolistTask.where(trainee_id:, challenge_id:,
                           date:).update_all(status: 'completed')
      end

      streak_counters = controller.calculate_streak(trainee_id, challenge_id, Date.today + 4.days)
      puts "hello #{streak_counters}}"
      expect(streak_counters.values).to all(eq(4)) # Assuming 5 days in the streak
    end

    it 'breaks streak when task is not completed' do
      TodolistTask.where(trainee_id:, challenge_id:,
                         date: Date.today).update_all(status: 'not_completed')

      streak_counters = controller.calculate_streak(trainee_id, challenge_id, Date.today + 4.days)
      expect(streak_counters.values).to all(eq(0))
    end

    it 'handles tasks on different dates' do
      (Date.today..Date.today + 4.days).each do |date|
        TodolistTask.where(trainee_id:, challenge_id:,
                           date:).update_all(status: 'completed')
      end

      TodolistTask.where(trainee_id:, challenge_id:,
                         date: Date.today).update_all(status: 'not_completed')

      streak_counters = controller.calculate_streak(trainee_id, challenge_id, Date.today + 4.days)
      expect(streak_counters.values).to all(eq(3))
    end
  end
end
