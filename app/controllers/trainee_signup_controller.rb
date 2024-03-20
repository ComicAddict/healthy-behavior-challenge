# frozen_string_literal: true

class TraineeSignupController < ApplicationController
  def new
    @user = User.new
    @trainee = Trainee.new
  end

  def create
    @user = User.new(user_params)
    @user.user_type = 'trainee'

    @trainee = Trainee.new(trainee_params)

    if @user.save

      @trainee.user = @user
      if @trainee.save
        redirect_to login_path, notice: 'Signup successful!'
      else
        @user.destroy
        render :new
      end
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def trainee_params
    # params.require(:trainee).permit(:full_name, :height, :weight)
    params.require(:user).permit(:full_name, :height_feet, :height_inches, :weight)
  end
end
