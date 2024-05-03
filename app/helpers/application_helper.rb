# frozen_string_literal: true

module ApplicationHelper
  def signed_in?
    !!session[:user_id]
  end

  def current_user
    @current_user = User.find(session[:user_id])
  end
end
