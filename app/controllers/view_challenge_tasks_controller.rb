# frozen_string_literal: true

class ViewChallengeTasksController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :task_not_found

  def index
    @user = User.find(session[:user_id])
  end

  def challenge_details
    @user = User.find(session[:user_id])
    @challenge = Challenge.find(params[:id])

    @is_instructor = @user.user_type.downcase == 'instructor'
    if @is_instructor
      @instructor = Instructor.find_by(user_id: @user.id)
      redirect_to instructor_path(@instructor) if @instructor
      return
    else
      @trainee_id = Trainee.where(user_id: @user.id)
    end
    @today = Date.today
    @challenge_to_do_lists = []

    (@challenge.startDate..@challenge.endDate).each do |ch_date|
      @todo_list = TodolistTask.where(trainee_id: @trainee_id, challenge_id: params[:id], date: ch_date).pluck(:task_id,
                                                                                                               :status, :date, :numbers)

      @challenge_to_do_lists << { challenge: @challenge, todo_list: @todo_list, date: ch_date }
    end
  end

  def task_not_found
    flash[:alert] = 'task not found.'
    redirect_to view_challenge_tasks_path(id: params[:id])
  end
end
