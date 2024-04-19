# frozen_string_literal: true

class User < ApplicationRecord
  include SimpleDiscussion::ForumUser

  def name
    "#{name}"
  end
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true
  has_many :instructor_referrals
  validates_uniqueness_of :email
end
