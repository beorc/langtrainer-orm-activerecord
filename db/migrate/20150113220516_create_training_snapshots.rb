class CreateTrainingSnapshots < ActiveRecord::Migration
  def change
    create_table :training_snapshots do |t|
      t.references :training, index: false
      t.text :snapshot, null: false
      t.datetime :date, null: false

      t.timestamps null: false

      t.index [:training_id, :date]
      t.index :date
    end
    add_foreign_key :training_snapshots, :trainings
  end
end
