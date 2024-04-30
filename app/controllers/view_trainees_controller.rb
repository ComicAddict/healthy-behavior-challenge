# frozen_string_literal: true

# allow instructor view information about selected trainee
class ViewTraineesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :trainee_not_found

  def index
    @trainees = Trainee.all
    @deactivated_trainees = DeactivatedTrainee.all

    @trainees_present = @trainees.exists?
    @deactivated_trainees_present = @deactivated_trainees.exists?
  end

  def profile_details
    @trainee = Trainee.find(params[:id])
  end

  def deactivated_profile_details
    @trainee = DeactivatedTrainee.find(params[:id])
    render 'profile_details'
  end

  def deactivate
    active_trainee = Trainee.find(params[:id])

    ChallengeTrainee.where(trainee: active_trainee).destroy_all
    TodolistTask.where(trainee: active_trainee).destroy_all

    DeactivatedTrainee.transaction do
      DeactivatedTrainee.create!(active_trainee.attributes.except('id', 'created_at', 'updated_at'))
      active_trainee.destroy!
    end
  rescue StandardError => e
    flash[:alert] = "Failed to deactivate trainee: #{e.message}"
  ensure
    redirect_to view_trainees_path
  end

  def activate
    deactivated_trainee = DeactivatedTrainee.find(params[:id])

    Trainee.transaction do
      Trainee.create!(deactivated_trainee.attributes.except('id', 'created_at', 'updated_at', 'original_trainee_id'))
      deactivated_trainee.destroy!
    end

    flash[:notice] = 'Trainee has been activated.'
  rescue StandardError => e
    flash[:alert] = "Failed to activate trainee: #{e.message}"
  ensure
    redirect_to view_trainees_path
  end

  def destroy_deactivated
    deactivated_trainee = DeactivatedTrainee.find(params[:id])
    deactivated_trainee.destroy!
    flash[:notice] = 'Trainee has been permanently deleted.'
  rescue ActiveRecord::RecordNotDestroyed
    flash[:alert] = 'Failed to delete the trainee.'
  ensure
    redirect_to view_trainees_path
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
