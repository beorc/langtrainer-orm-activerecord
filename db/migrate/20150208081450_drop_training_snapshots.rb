class DropTrainingSnapshots < ActiveRecord::Migration
  def change
    drop_table :training_snapshots
  end
end
