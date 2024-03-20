# frozen_string_literal: true

class Trainee < ApplicationRecord
  belongs_to :user

  validates :full_name, presence: true
  validates :height_feet, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :height_inches, presence: true,
                            numericality: { greater_than_or_equal_to: 0, less_than: 12, only_integer: true }
  validates :weight, presence: true, numericality: { greater_than: 0 }

  has_many :challenge_trainees
  has_many :todolist_tasks
  has_many :challenges, through: :challenge_trainees
end
