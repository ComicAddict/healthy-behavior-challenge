# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ViewTraineesController, type: :controller do
  before do
    user = User.create!(email: 'john@example.com', password: 'password')
    @trainee = Trainee.create!(full_name: 'John Someone', height_feet: 5, height_inches: 4, weight: 85, user:)
    @deactivated_trainee = DeactivatedTrainee.create!(full_name: 'Mary Jane', height_feet: 5, height_inches: 5, weight: 130, user:)
    # @trainee_to_deactivate = Trainee.create!(full_name: 'James Smith', height_feet: 5, height_inches: 4, weight: 85, user:)
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
    DeactivatedTrainee.destroy_all

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

  describe 'GET #deactivated_profile_details' do
    it 'assigns the requested deactivated trainee to @trainee' do
      get :deactivated_profile_details, params: { id: @deactivated_trainee.id }
      expect(assigns(:trainee)).to eq(@deactivated_trainee)
    end

    it 'renders the shared :profile_details view' do
      get :deactivated_profile_details, params: { id: @deactivated_trainee.id }
      expect(response).to render_template :profile_details
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

  describe 'POST #deactivate' do
    it 'successfully deactivates an active trainee' do
      post :deactivate, params: { id: @trainee.id }
      expect(response).to redirect_to(view_trainees_path)
    end

    it 'handles failure to deactivate a trainee' do
      allow_any_instance_of(Trainee).to receive(:destroy!).and_raise(StandardError.new('Custom error'))
      post :deactivate, params: { id: @trainee.id }
      expect(response).to redirect_to(view_trainees_path)
      expect(flash[:alert]).to match('Failed to deactivate trainee: Custom error')
    end
  end

  describe 'POST #activate' do
    it 'successfully activates a deactivated trainee' do
      post :activate, params: { id: @deactivated_trainee.id }

      expect(response).to redirect_to(view_trainees_path)
      expect(DeactivatedTrainee.exists?(@deactivated_trainee.id)).to be false
      expect(Trainee.exists?(full_name: 'Mary Jane')).to be true
      expect(flash[:notice]).to match('Trainee has been activated.')
    end

    it 'handles failure to activate a trainee' do
      allow_any_instance_of(DeactivatedTrainee).to receive(:destroy!).and_raise(StandardError.new('Custom error'))

      post :activate, params: { id: @deactivated_trainee.id }

      expect(response).to redirect_to(view_trainees_path)
      expect(flash[:alert]).to match('Failed to activate trainee: Custom error')
    end
  end

  describe 'DELETE #destroy_deactivated' do
    it 'successfully deletes a deactivated trainee' do
      delete :destroy_deactivated, params: { id: @deactivated_trainee.id }

      expect(response).to redirect_to(view_trainees_path)
      expect(flash[:notice]).to eq('Trainee has been permanently deleted.')
      expect(DeactivatedTrainee.exists?(@deactivated_trainee.id)).to be false
    end

    it 'handles failure to delete a deactivated trainee' do
      allow_any_instance_of(DeactivatedTrainee).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed)

      delete :destroy_deactivated, params: { id: @deactivated_trainee.id }

      expect(response).to redirect_to(view_trainees_path)
      expect(flash[:alert]).to match('Failed to delete the trainee.')
    end
  end
end
