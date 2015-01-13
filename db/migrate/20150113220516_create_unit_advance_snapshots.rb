class CreateUnitAdvanceSnapshots < ActiveRecord::Migration
  def change
    create_table :unit_advance_snapshots do |t|
      t.references :unit_advance, index: false, null: false
      t.text :snapshot, null: false
      t.datetime :date, null: false

      t.timestamps

      t.index [:unit_advance_id, :date]
      t.index :date
    end
    add_foreign_key :unit_advance_snapshots, :unit_advances
  end
end
