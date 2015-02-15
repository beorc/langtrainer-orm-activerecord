class AddScheduleToTrainings < ActiveRecord::Migration
  def change
    add_column :trainings, :schedule, :text
  end
end
