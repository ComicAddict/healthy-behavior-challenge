# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TraineeProfileController, type: :controller do
  describe 'GET #show' do
    context 'when trainee is found' do
      let(:user_id) { 1 } # Replace with the specific user ID used for testing

      before do
        allow(Trainee).to receive(:find_by).and_return(Trainee.new) # Stub the Trainee model
        get :show, session: { user_id: }
      end

      it 'assigns @trainee' do
        expect(assigns(:trainee)).to be_a(Trainee)
      end

      it 'renders the show template' do
        expect(response).to render_template(:show)
      end
    end

    context 'when trainee is not found' do
      let(:user_id) { 2 } # Replace with a user ID that won't find a trainee

      before do
        allow(Trainee).to receive(:find_by).and_return(nil) # Stub the Trainee model
        get :show, session: { user_id: }
      end

      it 'redirects to root path' do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'GET #edit' do
    context 'when user is logged in' do
      let(:user) { create(:user) }
      let!(:trainee) { create(:trainee, user:) }

      before do
        session[:user_id] = user.id
        get :edit
      end

      it 'assigns @trainee' do
        expect(assigns(:trainee)).to eq(trainee)
      end

      it 'renders the edit template' do
        expect(response).to render_template(:edit)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to root path' do
        get :edit
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH #update' do
    let(:user) { create(:user) }
    let!(:trainee) { create(:trainee, user:) }

    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      context 'with valid params' do
        let(:valid_params) { { trainee: { full_name: 'Updated Name', height_feet: 6, height_inches: 9, weight: 75 } } }

        it 'updates the trainee profile' do
          patch :update, params: valid_params
          trainee.reload
          expect(trainee.full_name).to eq('Updated Name')
          expect(trainee.height_feet).to eq(6)
          expect(trainee.height_inches).to eq(9)
          expect(trainee.weight).to eq(75)
        end

        it 'redirects to trainee profile path' do
          patch :update, params: valid_params
          expect(response).to redirect_to(trainee_profile_path)
        end

        it 'sets a notice message' do
          patch :update, params: valid_params
          expect(flash[:notice]).to eq('Profile updated successfully.')
        end
      end

      context 'with invalid params' do
        let(:invalid_params) { { trainee: { height_feet: -5 } } }

        it 'does not update the trainee profile' do
          previous_name = trainee.full_name
          patch :update, params: invalid_params
          trainee.reload
          expect(trainee.full_name).to eq(previous_name)
        end

        it 'renders the edit template' do
          patch :update, params: invalid_params
          expect(response).to render_template(:edit)
        end
      end
    end

    context 'when user is not logged in' do
      it 'redirects to root path' do
        patch :update, params: { trainee: { full_name: 'Updated Name', height_feet: 6, height_inches: 9, weight: 75 } }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
