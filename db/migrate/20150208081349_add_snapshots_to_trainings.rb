class AddSnapshotsToTrainings < ActiveRecord::Migration
  def change
    add_column :trainings, :snapshots, :text
  end
end
