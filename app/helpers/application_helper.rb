# frozen_string_literal: true

module ApplicationHelper
  def signed_in?
    !!session[:user_id]
  end

  def current_user
    @current_user ||= session[:user_id] && User.find_by(id: session[:user_id])
  end
end
