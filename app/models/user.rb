# frozen_string_literal: true

class User < ApplicationRecord
  include SimpleDiscussion::ForumUser

  def name
    "#{first_name} #{last_name}"
  end
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true
  validates :full_name, presence: true
  has_many :instructor_referrals
  validates_uniqueness_of :email
end
