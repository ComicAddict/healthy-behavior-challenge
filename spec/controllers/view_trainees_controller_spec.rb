# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ViewTraineesController, type: :controller do
  before do
    user = User.create!(email: 'john@example.com', password: 'password')
    @trainee = Trainee.create!(full_name: 'John Someone', height_feet: 5, height_inches: 4, weight: 85, user:)

    instructor_user = User.create!(email: 'instructor@example.com', password: 'securepassword', user_type: 'instructor')
    instructor = Instructor.create!(user: instructor_user, first_name: 'Jane', last_name: 'Doe')

    @challenge = Challenge.create!(name: 'Challenge Name', startDate: Date.yesterday, endDate: Date.tomorrow,
                                   instructor:)
    @task = Task.create!(taskName: 'Task Name')
    TodolistTask.create!(task: @task, challenge: @challenge, trainee: @trainee, status: 'completed', date: Date.today)
    ChallengeTrainee.create!(trainee: @trainee, challenge: @challenge)
  end

  after do
    ChallengeTrainee.destroy_all
    TodolistTask.destroy_all
    Challenge.destroy_all
    Task.destroy_all
    Trainee.destroy_all
    Instructor.destroy_all
    User.destroy_all
  end

  describe 'GET #index' do
    it 'populates an array of all trainees' do
      get :index
      expect(assigns(:trainees)).to eq([@trainee])
    end

    it 'renders the :index view' do
      get :index
      expect(response).to render_template :index
    end
  end

  describe 'GET #profile_details' do
    it 'assigns the requested trainee to @trainee' do
      get :profile_details, params: { id: @trainee.id }
      expect(assigns(:trainee)).to eq(@trainee)
    end

    it 'renders the :profile_details view' do
      get :profile_details, params: { id: @trainee.id }
      expect(response).to render_template :profile_details
    end
  end

  describe 'GET #profile_details for non-existent trainee' do
    it 'redirects to the view_trainees index view' do
      get :profile_details, params: { id: 'non-existent-id' }
      expect(response).to redirect_to(view_trainees_path)
    end

    it 'sets an alert message' do
      get :profile_details, params: { id: 'non-existent-id' }
      expect(flash[:alert]).to match(/Trainee not found./)
    end
  end

  describe 'GET #progress' do
    it 'assigns the requested trainee and tasks to @trainee and @tasks' do
      get :progress, params: { trainee_id: @trainee.id, challenge_id: @challenge.id }

      expect(assigns(:trainee)).to eq(@trainee)
      expect(assigns(:tasks)).not_to be_empty
    end
  end

  describe 'GET #challenges' do
    it 'assigns current and past challenges to @curr_challenges and @past_challenges' do
      get :challenges, params: { id: @trainee.id }

      expect(assigns(:curr_challenges)).to include(@challenge)
      expect(assigns(:past_challenges)).to be_empty
    end
  end

  describe 'GET #progress for non-existent trainee' do
    it 'redirects to the view_trainees index view with an alert' do
      get :progress, params: { trainee_id: 'non-existent-id', challenge_id: 'some-challenge-id' }
      expect(response).to redirect_to(view_trainees_path)
      expect(flash[:alert]).to match(/Trainee not found./)
    end
  end

  describe 'GET #challenges for non-existent trainee' do
    it 'redirects to the view_trainees index view with an alert' do
      get :challenges, params: { id: 'non-existent-id' }
      expect(response).to redirect_to(view_trainees_path)
      expect(flash[:alert]).to match(/Trainee not found./)
    end
  end
end
