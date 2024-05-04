# frozen_string_literal: true

FactoryBot.define do
  factory :deactivated_trainee do
    full_name { 'MyString' }
    height_feet { 1 }
    height_inches { 1 }
    weight { 1.5 }
    user { nil }
  end
end
