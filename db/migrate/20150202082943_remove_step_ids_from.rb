class RemoveStepIdsFrom < ActiveRecord::Migration
  def change
    remove_column :trainings, :step_ids
    remove_column :trainings, :revised
  end
end
