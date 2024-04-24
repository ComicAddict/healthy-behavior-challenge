# frozen_string_literal: true

class User < ActiveRecord::Base
  include SimpleDiscussion::ForumUser
  def name
    "#{email}"
  end
end
