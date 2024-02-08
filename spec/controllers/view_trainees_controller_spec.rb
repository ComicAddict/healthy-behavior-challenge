require 'rails_helper'

RSpec.describe ViewTraineesController, type: :controller do
  before do
    user = User.create!(email: "john@example.com", password: "password")
    @trainee = Trainee.create!(full_name: "John Doe", height: 165, weight: 85, user: user)
  end

  describe "GET #index" do
    it "populates an array of all trainees" do
      get :index
      expect(assigns(:trainees)).to eq([@trainee])
    end

    it "renders the :index view" do
      get :index
      expect(response).to render_template :index
    end
  end

  describe "GET #profile_details" do
    it "assigns the requested trainee to @trainee" do
      get :profile_details, params: { id: @trainee.id }
      expect(assigns(:trainee)).to eq(@trainee)
    end

    it "renders the :profile_details view" do
      get :profile_details, params: { id: @trainee.id }
      expect(response).to render_template :profile_details
    end
  end
end
