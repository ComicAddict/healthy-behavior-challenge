# frozen_string_literal: true

class AddGenericNumberFieldsToTodoListTask < ActiveRecord::Migration[7.0]
  def change
    add_column :todolist_tasks, :numbers, :float, array: true, default: []
    add_column :tasks, :numbers, :float, array: true, default: []
  end
end
