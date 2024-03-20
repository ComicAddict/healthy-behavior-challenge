# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

user = User.create!(email: 'healthybehaviorchallenge@gmail.com', password: 'asdf', user_type: 'Instructor')
Instructor.create!(user_id: user.id, first_name: 'HBCMainInstructor', last_name: 'HBCMainInstructor_lastName')

tasks_data = [
  { taskName: 'Drink 8 Cups of Water', saved_status: 1 },
  { taskName: 'Exercise for at least 30 min', saved_status: 1 },
  { taskName: 'Eat a serving of vegetables', saved_status: 1 }
]

tasks_data.each do |task_data|
  task = Task.find_or_initialize_by(taskName: task_data[:taskName])
  task.saved_status = task_data[:saved_status]
  task.save
end
