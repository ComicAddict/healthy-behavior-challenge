# frozen_string_literal: true

class CreateDeactivatedTrainees < ActiveRecord::Migration[7.0]
  def change
    create_table :deactivated_trainees do |t|
      t.string :full_name
      t.integer :height_feet
      t.integer :height_inches
      t.float :weight
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
