# frozen_string_literal: true

FactoryBot.define do
  factory :trainee do
    full_name { 'Trainee' }
    height_feet { 5 }
    height_inches { 8 }
    weight { 11 }
  end
end
