# frozen_string_literal: true

class ViewChallengeTasksController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :task_not_found

  def index
    @user = User.find(session[:user_id])
  end

  def challenge_details
    @user = User.find(session[:user_id])
    @challenge = Challenge.find_by(id: params[:id])

    @user = User.find(session[:user_id])
    @is_instructor = @user.user_type.downcase == 'instructor'
    if @is_instructor
      @instructor = Instructor.find_by(user_id: @user.id)
      redirect_to instructor_path(@instructor) if @instructor
      return
    else
      trainee = Trainee.find_by(user_id: @user.id)
      @trainee = trainee
    end
    trainee_id = trainee.id

    @challenge_to_do_lists = []
    @trainee_challenges = ChallengeTrainee.where(trainee_id:)

    @challenge = Challenge.find_by(id: params[:id])

    selected_date = params[:selected_date]
    if selected_date.blank?
      selected_date = params.dig(:user, :selected_date)
      current_date = if selected_date.blank?
                       Date.today
                     else
                       Date.parse(selected_date)
                     end
    else
      current_date = Date.parse(selected_date)
    end
    (@challenge.startDate...@challenge.endDate).each do |ch_date|
      @todo_list = TodolistTask.where(trainee_id:, challenge_id: params[:id], date: ch_date).pluck(:task_id,
                                                                                                   :status, :date, :numbers)
      @challenge_to_do_lists << { challenge: @challenge, todo_list: @todo_list, date: ch_date }
    end

    @date = current_date

    return if @challenge

    flash[:alert] = 'task not found.'
    redirect_to view_challenge_tasks_detail_path
    nil
  end

  def challenge_not_found
    flash[:alert] = 'task not found.'
    redirect_to view_challenge_tasks_detail_path
  end
end
