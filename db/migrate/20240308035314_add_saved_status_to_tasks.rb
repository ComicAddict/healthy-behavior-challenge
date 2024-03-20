# frozen_string_literal: true

class AddSavedStatusToTasks < ActiveRecord::Migration[7.0]
  def change
    add_column :tasks, :saved_status, :integer, default: 0
  end
end
