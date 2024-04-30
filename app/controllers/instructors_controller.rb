# frozen_string_literal: true

require 'will_paginate/array'

class InstructorsController < ApplicationController
  def new
    token = InstructorReferral.find_by(token: params[:token])
    unless token.present? &&
           token.expires > DateTime.now &&
           !token.is_used?
      @token_invalid = true
    end
    @instructor = Instructor.new
    @user = User.new
  end

  def index; end

  def create
    if user_params[:password] != user_params[:confirm_password]
      flash[:error] = 'Password Mismatch.'
      redirect_to instructor_signup_path
      return
    end

    specific_user_params = {
      email: user_params[:email],
      password: user_params[:password],
      user_type: 'Instructor'
    }
    @user = User.new(specific_user_params)

    if valid_inputs?
      if @user.save

        specific_instructor_params = {
          user_id: @user.id,
          first_name: user_params[:first_name],
          last_name: user_params[:last_name]
        }

        @instructor = Instructor.new(specific_instructor_params)
        if @instructor.save
          flash[:notice] = "Welcome, #{@instructor.first_name}!"
          InstructorReferral.find_by(token: params[:token]).update(is_used: true)
          session[:user_id] = @user.id
          redirect_to user_path(session[:user_id])
        end
      end
    else
      # flash.now[:error] = "Please enter valid email and try again."
      render 'new'
    end
  end

  def show
    if user_signed_in?
      today = Date.today
      @instructor = Instructor.find(params[:instructor_id])
      @user_name_from_session = @instructor.first_name
      instructor_id = params[:instructor_id]
      @challenges = Challenge.where('"instructor_id" = ? AND "startDate" <= ? AND "endDate" >= ?', instructor_id,
                                    today, today).order('"endDate" ASC')
      @challenges = @challenges.paginate(page: params[:page], per_page: 7)
      @is_instructor = true if @instructor
      render :show, challenges: @challenges
    else
      redirect_to root_path
    end
  end

  def show_prev_challenges
    if user_signed_in?
      today = Date.today
      @instructor = Instructor.find(params[:instructor_id])
      @user_name_from_session = @instructor.first_name
      instructor_id = params[:instructor_id]
      @challenges = Challenge.where('"instructor_id" = ? AND "startDate" <= ? AND "endDate" <= ?', instructor_id,
                                    today, today).order('"endDate" ASC')
      @challenges = @challenges.paginate(page: params[:page], per_page: 7)
      @is_instructor = true if @instructor
      render :show_prev_challenges, challenges: @challenges
    else
      redirect_to root_path
    end
  end

  def show_future_challenges
    if user_signed_in?
      today = Date.today
      @instructor = Instructor.find(params[:instructor_id])
      @user_name_from_session = @instructor.first_name
      instructor_id = params[:instructor_id]
      @challenges = Challenge.where('"instructor_id" = ? AND "startDate" > ? AND "endDate" >= ?', instructor_id,
                                    today, today).order('"endDate" ASC')
      @challenges = @challenges.paginate(page: params[:page], per_page: 7)
      @is_instructor = true if @instructor
      render :show_future_challenges, challenges: @challenges
    else
      redirect_to root_path
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :confirm_password, :first_name, :last_name)
  end

  def valid_inputs?
    /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.match?(user_params[:email])
  end
end
