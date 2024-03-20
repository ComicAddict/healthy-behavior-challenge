# frozen_string_literal: true

class TraineeProfileController < ApplicationController
  def show
    @trainee = Trainee.find_by(user_id: session[:user_id])
    return if @trainee

    redirect_to root_path
    nil
  end

  def edit
    @trainee = Trainee.find_by(user_id: session[:user_id])
    return if @trainee

    redirect_to root_path
    nil
  end

  def update
    @trainee = Trainee.find_by(user_id: session[:user_id])
    if @trainee.nil?
      redirect_to root_path, alert: 'Trainee profile not found.'
      return
    end
    if @trainee.update(trainee_params)
      redirect_to trainee_profile_path, notice: 'Profile updated successfully.'
    else
      render :edit
    end
  end

  def trainee_params
    params.require(:trainee).permit(:full_name, :height_feet, :height_inches, :weight)
  end
end
