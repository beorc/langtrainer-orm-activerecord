class RenameStepsToStepIdsInTrainings < ActiveRecord::Migration
  def change
    rename_column :trainings, :steps, :step_ids
  end
end
