# frozen_string_literal: true

# app/controllers/challenges_controller.rb
class ChallengesController < ApplicationController
  include ChallengesHelper
  before_action :require_user

  def new
    @challenge = Challenge.new
    @instructor = Instructor.find_by(user_id: session[:user_id])
    Rails.logger.debug(@instructor)
    unless @instructor
      flash[:alert] = 'You are not an instructor.'
      redirect_to root_path
      return
    end
    @is_instructor = true
  end

  def create
    @challenge = Challenge.new(challenge_params)
    @instructor = Instructor.find_by(user_id: session[:user_id])
    @challenge.instructor = @instructor

    if Challenge.find_by(name: @challenge.name)
      flash[:alert] = 'A challenge with the same name already exists.'
      redirect_to new_challenge_path
      return
    end

    if params[:challenge][:startDate] > params[:challenge][:endDate]
      flash[:alert] = 'start date is greater than end date'
      redirect_to new_challenge_path
      return
    end

    existing_tasks = []

    if params[:challenge][:tasks_attributes].present?
      params[:challenge][:tasks_attributes].each do |task_attributes|
        task_name = task_attributes[1][:taskName]
        # Check if a task with the same name already exists
        existing_task = Task.find_by(taskName: task_name)

        if existing_task
          existing_tasks << existing_task
        else
          nums = task_name.scan(/(\d+\.?\d+)|(\d+)/).flatten.compact.map(&:to_f)
          new_task = Task.new(taskName: task_name, numbers: nums)
          existing_tasks << new_task
        end
      end
    end

    # Replace the task attributes with the existing tasks
    @challenge.tasks = existing_tasks

    return unless @challenge.save

    flash[:notice] = 'Challenge successfully created.'
    redirect_to new_challenge_path
    nil
  end

  def show
    @instructor = Instructor.find_by(user_id: session[:user_id])

    if @instructor
      begin
        @challenge = Challenge.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:alert] = 'Challenge not found.'
        redirect_to challenges_path
      end
    else
      flash[:notice] = 'You are not an instructor.'
      redirect_to root_path
    end
  end

  def trainees_list
    @challenge = Challenge.find(params[:challenge_id])
    trainees = Trainee.joins(:challenge_trainees).where(challenge_trainees: { challenge_id: params[:challenge_id] })
    params[:page].presence || 1
    @trainees_ct = trainees.size
    @trainees = trainees.paginate(page: params[:page], per_page: 10)
  end

  def add_trainees
    @challenge = Challenge.find(params[:id])
    # if @challenge.startDate <= Date.today
    #   flash.now[:alert] = 'Challenge has already started. You cannot add trainees.'
    #   @trainees = []
    # else
    @challenge_trainees = ChallengeTrainee.where(challenge_id: params[:id])
    trainee_ids = @challenge_trainees.pluck(:trainee_id)
    @trainees = Trainee.where.not(id: trainee_ids)
    # end
  end

  def update_trainees
    @challenge = Challenge.find(params[:id])
    trainee_ids = params[:trainee_ids].reject(&:blank?)
    if trainee_ids.empty?
      flash.now[:alert] = 'No trainee selected. Please select at least one trainee.'
      @challenge_trainees = ChallengeTrainee.where(challenge_id: params[:id])
      trainee_ids = @challenge_trainees.pluck(:trainee_id)
      @trainees = Trainee.where.not(id: trainee_ids)
      render 'add_trainees'
      return
    end
    if @challenge.trainees << Trainee.where(id: params[:trainee_ids])
      flash.now[:notice] = 'Trainees were successfully added to the challenge.'
      @new_trainees = Trainee.where(id: params[:trainee_ids])
      @new_trainees.each do |trainee|
        tasks = @challenge.tasks
        tasks.each do |task|
          (@challenge.startDate..@challenge.endDate).each do |date|
            tasktodo = TodolistTask.new(
              task:,
              trainee:,
              challenge: @challenge,
              date:,
              status: 'not_completed'
            )
            if tasktodo.save
              flash.now[:notice] = 'Trainees were successfully added to the challenge.'
            else
              flash.now[:alert] = 'Something went wrong. Challenge was not updated.'
            end
          end
        end
      end
    else
      flash.now[:alert] = 'Something went wrong. Challenge was not updated.'
    end
    @challenge_trainees = ChallengeTrainee.where(challenge_id: params[:id])
    trainee_ids = @challenge_trainees.pluck(:trainee_id)
    @trainees = Trainee.where.not(id: trainee_ids)
    render 'add_trainees'
  end

  def task_progress
    task_completed_counts = TodolistTask.where(trainee_id: params[:trainee_id], challenge_id: params[:id],
                                               status: 'completed').group(:date).count
    task_not_completed_counts = TodolistTask.where(trainee_id: params[:trainee_id], challenge_id: params[:id],
                                                   status: 'not_completed').group(:date).count
    start_date = Date.today - 7
    end_date = Date.today
    task_completed_counts_week = TodolistTask.where(trainee_id: params[:trainee_id], challenge_id: params[:id],
                                                    status: 'completed', date: start_date..end_date).group(:date).count
    task_not_completed_counts_week = TodolistTask.where(trainee_id: params[:trainee_id], challenge_id: params[:id],
                                                        status: 'not_completed', date: start_date..end_date).group(:date).count

    # Get the union of all dates from both completed and not completed tasks for all time
    all_dates = (task_completed_counts.keys | task_not_completed_counts.keys).sort

    # Initialize arrays for dates and counts with zero counts for all time
    @dates_completed = []
    @counts_completed = []
    @dates_not_completed = []
    @counts_not_completed = []
    @counts_total = []

    # Get the union of all dates from both completed and not completed tasks for all time
    all_dates_week = (task_completed_counts_week.keys | task_not_completed_counts_week.keys).sort

    # Initialize arrays for dates and counts with zero counts for all time
    @dates_completed_week = []
    @counts_completed_week = []
    @dates_not_completed_week = []
    @counts_not_completed_week = []
    @counts_total_week = []

    # Populate arrays with dates and counts, filling in zeros for missing dates
    all_dates.each do |date|
      @dates_completed << date
      @counts_completed << task_completed_counts[date].to_i
      @dates_not_completed << date
      @counts_not_completed << task_not_completed_counts[date].to_i
      @counts_total << task_completed_counts[date].to_i + task_not_completed_counts[date].to_i
    end

    # Populate arrays with dates and counts, filling in zeros for missing dates for the past week
    all_dates_week.each do |date|
      @dates_completed_week << date
      @counts_completed_week << task_completed_counts_week[date].to_i
      @dates_not_completed_week << date
      @counts_not_completed_week << task_not_completed_counts_week[date].to_i
      @counts_total_week << task_completed_counts_week[date].to_i + task_not_completed_counts_week[date].to_i
    end

    @trainee = Trainee.find_by(id: params[:trainee_id])
    @challenge = Challenge.find_by(id: params[:id])
    @trainee_name = @trainee.full_name if @trainee.present?

    @page_title = ''
    @instructor = Instructor.find_by(user_id: session[:user_id])
    @page_title = if @instructor
                    "Progress Overview: #{@trainee.full_name}"
                  else
                    "My Progress: #{@challenge.name}"
                  end
  end

  def filter_data
    selected_date = params[:selected_date]
    trainee_id = params[:trainee_id]
    challenge_id = params[:challenge_id]
    task_ids = TodolistTask.where(trainee_id:, challenge_id:,
                                  date: selected_date).pluck(:task_id)
    @todo_list = Task.where(id: task_ids)
    @filtered_data = @todo_list
    render json: @filtered_data
  end

  def show_challenge_trainee
    @challenge = Challenge.find(params[:challenge_id])
    @trainee = @challenge.trainees.find(params[:trainee_id])
    start_date = if @challenge.startDate
                   @challenge.startDate > Date.today ? @challenge.startDate : Date.today
                 else
                   Date.today
                 end

    task_ids = TodolistTask.where(trainee_id: @trainee.id, challenge_id: @challenge.id,
                                  date: start_date).pluck(:task_id)
    @todo_list = Task.where(id: task_ids)
    @filtered_data = @todo_list

    render 'show_challenge_trainee'
  end

  def edit
    @user = User.find(session[:user_id])
    @instructor = Instructor.find_by(user_id: session[:user_id])
    Rails.logger.debug(@instructor)
    unless @instructor
      flash[:notice] = 'You are not an instructor.'
      redirect_to root_path
      return
    end
    @challenge = Challenge.find(params[:id])
    task_ids = ChallengeGenericlist.where(challenge_id: @challenge.id).pluck(:task_id)
    @todo_list = Task.where(id: task_ids)
  end

  def update
    @challenge = Challenge.find(params[:id])
    @user = User.find(session[:user_id])
    @instructor = Instructor.find_by(user_id: session[:user_id])

    current_start_date = @challenge.startDate
    current_end_date = @challenge.endDate

    if current_end_date < Date.today
      flash[:alert] = 'Challenge has already ended. You cannot edit it'
      redirect_to challenge_path
      return
    end

    end_date_params = Date.parse(params[:task][:end_date])

    start_date = Date.parse(params[:task][:start_date])
    if start_date == current_start_date
      if start_date <= Date.today
        start_date_params = Date.tomorrow

        if start_date_params > end_date_params
          flash[:alert] =
            'Challenge has already started. List will be updated from tomorrow and the start date exceeds the end date'
          redirect_to edit_challenge_path
          return
        end
      else
        start_date_params = start_date
      end
    else
      start_date_params = start_date
    end

    if start_date_params > end_date_params
      flash[:alert] = 'Start date cannot exceed end date'
      redirect_to edit_challenge_path
      return
    end

    trainee_ids = ChallengeTrainee.where(challenge_id: params[:id]).pluck(:trainee_id)
    @trainees = Trainee.where(id: trainee_ids)

    @trainees.each do |trainee_val|
      TodolistTask.where(trainee: trainee_val, challenge: @challenge,
                         date: start_date_params..end_date_params).destroy_all
    end

    ChallengeGenericlist.where(challenge_id: @challenge.id).destroy_all

    # Process submitted tasks
    if params.key?(:task)
      task_from_params = params.dig(:task, :tasks)

      if task_from_params.present?
        task_from_params.each do |id, task_params|
          existing_task = Task.find(id)
          nums = task_params[:taskName].scan(/(\d+\.?\d+)|(\d+)/).flatten.compact.map(&:to_f)
          if existing_task.taskName != task_params[:taskName]
            task = Task.create(taskName: task_params[:taskName], numbers: nums)
            task.id
          else
            task = existing_task
          end

          @trainees.each do |trainee_val|
            (start_date_params..end_date_params).each do |date|
              TodolistTask.create(
                trainee: trainee_val,
                challenge: @challenge,
                task:,
                date:,
                status: 'not_completed',
                numbers: nums
              )
            end
          end

          ChallengeGenericlist.create(task:, challenge: @challenge)
        end
      end
    end

    new_tasks = params[:tasks]
    if new_tasks && !new_tasks.empty?
      new_tasks.each_value do |task_params|
        nums = task_params[:taskName].scan(/(\d+\.?\d+)|(\d+)/).flatten.compact.map(&:to_f)
        existing_task = Task.find_by(taskName: task_params[:taskName], numbers: nums)
        task = existing_task || Task.create(taskName: task_params[:taskName], numbers: nums)

        @trainees.each do |trainee_val|
          (start_date_params..end_date_params).each do |date|
            TodolistTask.create(
              trainee: trainee_val,
              challenge: @challenge,
              task:,
              date:,
              status: 'not_completed',
              numbers: nums
            )
          end
        end

        ChallengeGenericlist.create(task:, challenge: @challenge)
      end
    end

    @challenge.startDate = start_date_params if start_date != current_start_date
    @challenge.endDate = end_date_params
    @challenge.save

    flash[:notice] = 'Challenge was successfully updated'
    redirect_to edit_challenge_path
  end

  def delete_trainee
    @challenge = Challenge.find(params[:challenge_id])
    @trainee = Trainee.find(params[:trainee_id])
    challenge_trainee = ChallengeTrainee.find_by(challenge_id: @challenge.id, trainee_id: @trainee.id)

    challenge_trainee&.destroy
    redirect_to challenge_list_trainees_path(challenge_id: params[:challenge_id])
  end

  private

  def challenge_params
    params.require(:challenge).permit(:name, :id, :startDate, :endDate,
                                      tasks_attributes: %i[id taskName task_id _destroy])
  end

  def require_user
    return if user_signed_in?

    flash[:alert] = 'You must be signed in to access this page.'
    redirect_to login_path
  end
end
