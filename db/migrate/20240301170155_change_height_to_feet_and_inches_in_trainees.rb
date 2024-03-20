# frozen_string_literal: true

class ChangeHeightToFeetAndInchesInTrainees < ActiveRecord::Migration[7.0]
  def change
    remove_column :trainees, :height, :float
    add_column :trainees, :height_feet, :integer
    add_column :trainees, :height_inches, :integer
  end
end
