# frozen_string_literal: true

require 'rails_helper'

describe Trainee, type: :model do
  describe 'validations' do
    it 'is invalid without an name' do
      trainee = Trainee.new(full_name: nil)
      expect(trainee).to be_invalid
    end

    it 'is invalid with a negative height in feet' do
      trainee = Trainee.new(height_feet: -1)
      expect(trainee).to be_invalid
    end

    it 'is invalid with a negative height in inches' do
      trainee = Trainee.new(height_inches: -1)
      expect(trainee).to be_invalid
    end

    it 'is invalid with a height in inches over 11' do
      trainee = Trainee.new(height_inches: 12)
      expect(trainee).to be_invalid
    end

    it 'is invalid with a negative weight' do
      trainee = Trainee.new(weight: -5)
      expect(trainee).to be_invalid
    end

    it 'is invalid with a weight of zero' do
      trainee = Trainee.new(weight: 0)
      expect(trainee).to be_invalid
    end
  end
end
