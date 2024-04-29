# frozen_string_literal: true

require 'securerandom'

class InstructorReferralController < ApplicationController
  before_action :require_user

  def index
    # Add any logic needed for the instructor referral page here
  end

  def create
    @user = User.find(session[:user_id])
    @token = SecureRandom.uuid
    @referral = @user.instructor_referrals.create(email: params[:email], token: @token, expires: Date.today + 7.days)
    errors = @referral.errors.full_messages
    if !errors.empty?
      flash.now[:error] = "Error: #{errors.join(', ')}"
    else
      @referral.save
      InstructorReferralMailer.with(referral: @referral, email: params[:email], is_used: false).refer.deliver_now
      flash.now[:notice] = "#{ENV['ROOT_URL']}#{instructor_signup_path(token: @referral.token)}"
    end
    render action: 'index'
  end

  private

  def require_user
    return if user_signed_in?

    flash[:alert] = 'You must be signed in to access this page.'
    redirect_to login_path
  end
end
