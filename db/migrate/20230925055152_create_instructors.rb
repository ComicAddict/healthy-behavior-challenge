# frozen_string_literal: true

class CreateInstructors < ActiveRecord::Migration[7.0]
  def change
    create_table :instructors do |t|
      t.references :user, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
