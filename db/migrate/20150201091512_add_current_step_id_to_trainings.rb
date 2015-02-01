class AddCurrentStepIdToTrainings < ActiveRecord::Migration
  def change
    remove_column :trainings, :current_step
    add_column :trainings, :current_step_id, :integer
  end
end
