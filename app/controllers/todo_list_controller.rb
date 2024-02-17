class TodoListController < ApplicationController
  before_action :require_user

    def new 
        #@user = User.new
        #@trainee = Trainee.new
    end

    def show
        @user = User.find(session[:user_id])
        @is_instructor = @user.user_type.downcase == "instructor"
        if @is_instructor
            @instructor = Instructor.find_by(user_id: @user.id)
            if @instructor
                redirect_to instructor_path(@instructor)
            end
            return
        else
            trainee = Trainee.find_by(user_id: @user.id)
            @trainee = trainee
        end
        trainee_id = trainee.id

        @challenge_to_do_lists = []
        @trainee_challenges = ChallengeTrainee.where(trainee_id: trainee_id)
        @trainee_challenges.each do |trainee_challenge|
            trainee_challenge_id = trainee_challenge.challenge_id
            @challenge = Challenge.find_by(id: trainee_challenge_id)

            selected_date = params[:selected_date]
            if selected_date.blank?
                selected_date = params.dig(:user, :selected_date)
                if selected_date.blank?
                    current_date = Date.today
                else
                    current_date = Date.parse(selected_date)
                end
            else
                current_date = Date.parse(selected_date)
            end
            @todo_list = TodolistTask.where(trainee_id: trainee_id, challenge_id: trainee_challenge_id, date: current_date).pluck(:task_id, :status)
            @date = current_date
            if(current_date<=@challenge.endDate and current_date>=@challenge.startDate)
                streak = calculate_streak(trainee_id,trainee_challenge_id, current_date)
                @challenge_to_do_lists << { challenge: @challenge, todo_list: @todo_list, streak: streak }
            end
        end
    end
      
    def mark_as_completed
        if params[:user].present? && params[:user][:tasks].present?
            user_tasks = params[:user][:tasks]
        else
            redirect_to todo_list_path, notice: 'No Tasks'
            return
        end

        today_date = Date.today
        @user = User.find(session[:user_id])
        trainee = Trainee.find_by(user_id: @user.id)
        trainee_id = trainee.id

        user_tasks.each do |task_id, task_data|
            task_id = task_data[:task_id]
            challenge_id = task_data[:challenge_id]
            completed = task_data[:completed]
            current_date = task_data[:date]
            status = completed == '1' ? 'completed' : 'not_completed'

            @date = current_date
            task = TodolistTask.find_by(
                trainee_id: trainee_id,
                task_id: task_id,
                challenge_id: challenge_id,
                date: current_date
            )
        
            if task
                if status == "completed" 
                  task.update(status: status)
                end
            end
        end
        
        redirect_to todo_list_path(selected_date: @date), notice: 'Tasks have been updated.'
    end   
  
    def update
      @user = User.find(session[:user_id])

      if @user.user_type == "Instructor"
        # Handle task updates and deletions for instructors
        @trainee = Trainee.find(params[:trainee_id])
        @challenge = Challenge.find(params[:challenge_id])

        # Parse the start and end dates from the form
        start_date = Date.parse(params[:task][:start_date])
        end_date = Date.parse(params[:task][:end_date])

        # Check if the provided dates are within the challenge's start and end dates
        if start_date < @challenge.startDate || end_date > @challenge.endDate
          flash[:notice] = "Date range must be within the challenge's start and end dates."
          redirect_to edit_trainee_todo_list_path(@trainee, @challenge)
          return
        elsif start_date <= Date.today
          flash[:notice] = "Challenge has already started! Choose a start date from tomorrow onwards."
          redirect_to edit_trainee_todo_list_path(@trainee, @challenge)
          return
        end

        TodolistTask.where(trainee: @trainee, challenge: @challenge, date: start_date..end_date).destroy_all 

        # Process submitted tasks
        if params.has_key?(:task)
          task_from_params = params.dig(:task, :tasks)

          if task_from_params.present?
            task_from_params.each do |id, task_params|
              existing_task = Task.find(id)

              if existing_task.taskName != task_params[:taskName]
                # Name changed, make a new task
                task = Task.create(taskName: task_params[:taskName])
                id = task.id # Update the id
              else
                task = existing_task
              end

              (start_date..end_date).each do |date|
                TodolistTask.create(
                  trainee: @trainee, 
                  challenge: @challenge,
                  task: task,
                  date: date,
                  status: 'not_completed'
                )
              end
            end
          end
        end

        new_tasks = params[:tasks]
        if new_tasks && !new_tasks.empty?
          new_tasks.each do |id, task_params|
            existing_task = Task.find_by(taskName: task_params[:taskName])

            if existing_task
              # Use existing task
              task = existing_task 
            else
              # Create new task
              task = Task.create(taskName: task_params[:taskName])
            end

            (start_date..end_date).each do |date|
              TodolistTask.create(
                trainee: @trainee, 
                challenge: @challenge,
                task: task,
                date: date,
                status: 'not_completed'
              )
            end
          end
        end

        redirect_to edit_trainee_todo_list_path(@trainee, @challenge), notice: "Tasks successfully updated."
      else
        trainee = Trainee.find_by(user_id: @user.id)
        trainee_id = trainee.id
        trainee_challenge_id = ChallengeTrainee.find_by(trainee_id: trainee_id).challenge_id
        current_date = Date.today
        task_params = params[:tasks] || {} 
        task_params.each do |task_id, status|
          TodolistTask.find_by(id: task_id, date: @date).update(status: status)
        end
        @todo_list = TodolistTask.where(trainee_id: trainee_id, challenge_id: trainee_challenge_id, date: current_date).pluck(:task_id, :status)
        @date = current_date
        redirect_to todo_list_path, notice: 'Tasks have been updated.'
      end
    end

    def edit
            @instructor = Instructor.find_by(user_id: session[:user_id])

        if @instructor
            @trainee = Trainee.find(params[:trainee_id])
            @challenge = Challenge.find(params[:challenge_id])
                
            if @challenge.startDate <= Date.today
                todo_date = Date.today
            else
                todo_date = @challenge.startDate
            end
                
            task_ids = TodolistTask.where(trainee_id: @trainee.id, challenge_id: @challenge.id, date: todo_date).pluck(:task_id)
            @todo_list = Task.where(id: task_ids)
        else
            flash[:notice] = "You are not an instructor."
            redirect_to root_path
        end
    end

    def calculate_streak(trainee_id, challenge_id, current_date)
      todolist_tasks = TodolistTask.where(trainee_id: trainee_id, challenge_id: challenge_id).order(date: :asc)

    
      streak_counters = Hash.new(0)
      current_streak = 0
    
      todolist_tasks.each do |task|
        break if task.date == current_date
        streak_counters[task.task_id] ||= 0
        if task.status == 'completed'
          streak_counters[task.task_id]  += 1
        else
          streak_counters[task.task_id]  = 0
        end

      end
    
      streak_counters
    end

    def calc_month_status(trainee_id, challenge_id, start_date, end_date)
      todolist_tasks = TodolistTask.where(date: start_date..end_date, trainee_id: trainee_id, challenge_id: challenge_id).order(date: :asc)
      
      #dates = [*1..31]
      challengeStatus = Array.new(31,0)
      todolist_tasks.each do |task|
        taskdateindex = task.date[-2..-1].to_i - 1  
        if task.status == 'completed'
          challengeStatus[taskdateindex] = 1
        end
      end
    
      challengeStatus
    end

    private
    
    def require_user
      unless user_signed_in? 
        flash[:alert] = "You must be signed in to access this page."
        redirect_to login_path
      end
    end

end