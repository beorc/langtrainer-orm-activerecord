class CreateStepsUnits < ActiveRecord::Migration
  def change
    create_table :steps_units do |t|
      t.references :unit, index: false
      t.references :step, index: true
      t.integer :position
      t.boolean :from_en, default: true
      t.boolean :to_en, default: true
      t.boolean :from_ru, default: true
      t.boolean :to_ru, default: true

      t.index :position
      t.index [:step_id, :unit_id], unique: true
    end
    add_foreign_key :steps_units, :units
    add_foreign_key :steps_units, :steps
  end
end
