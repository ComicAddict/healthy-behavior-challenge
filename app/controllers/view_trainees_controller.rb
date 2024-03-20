# frozen_string_literal: true

# allow instructor view information about selected trainee
class ViewTraineesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :trainee_not_found

  def index
    @trainees = Trainee.all
    @trainees_present = @trainees.exists?
  end

  def profile_details
    @trainee = Trainee.find(params[:id])
  end

  def progress
    @trainee = Trainee.find(params[:trainee_id])
    @challenge = Challenge.find(params[:challenge_id])
    @tasks = TodolistTask.includes(:task).where(challenge_id: @challenge.id, trainee_id: @trainee.id)
    @dates = (@challenge.startDate..@challenge.endDate).to_a
  end

  def challenges
    @trainee = Trainee.find(params[:id])
    @curr_challenges = @trainee.challenges.where('"challenges"."startDate" <= ? AND "challenges"."endDate" >= ?',
                                                 Date.today, Date.today).order('"challenges"."endDate" ASC')
    @past_challenges = @trainee.challenges.where('"challenges"."endDate" < ?',
                                                 Date.today).order('"challenges"."endDate" ASC')
  end

  def trainee_not_found
    flash[:alert] = 'Trainee not found.'
    redirect_to view_trainees_path
  end
end
