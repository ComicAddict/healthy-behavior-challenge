# frozen_string_literal: true

class User < ActiveRecord::Base
  include SimpleDiscussion::ForumUser
  has_secure_password
  def name
    "#{email}"
  end
end
